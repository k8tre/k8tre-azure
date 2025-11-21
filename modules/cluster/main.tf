terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
  required_version = ">= 1.7.0, < 2.0.0"
}

#
# k8s private aks cluster
#

provider "azurerm" {
  alias           = "azure-cluster"
  subscription_id = var.k8tre_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-connectivity"
  subscription_id = var.k8tre_connectivity_subscription_id
  features {}
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = format("rg-%s-%s-uks-aks", var.service_name, var.environment)
  location = var.region
  provider = azurerm.azure-cluster

  tags = {
    Service        = "AKS Cluster"
    ServiceName    = var.service_name
    "Service Name" = var.service_name

    "Service Owner" = "s-m.harding"
    ServiceOwner    = "s-m.harding"

    "Cost Centre" = "ICT"
    CostCentre    = "ICT"
    Environment   = var.environment
  }
}

data "azurerm_virtual_network" "cluster_spoke_vnet" {
  name                = format("vnet-kare-%s-uks-spoke", var.environment)
  resource_group_name = format("rg-kare-%s-uks-network", var.environment)
  provider            = azurerm.azure-cluster
}


data "azurerm_subnet" "cluster_spoke_aks_node_subnet" {
  name                 = "snet-clusternodes"
  virtual_network_name = data.azurerm_virtual_network.cluster_spoke_vnet.name
  resource_group_name  = data.azurerm_virtual_network.cluster_spoke_vnet.resource_group_name
  provider             = azurerm.azure-cluster
}

# Identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = format("managed-id-%s-%s-cluster", var.service_name, var.environment)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  provider            = azurerm.azure-cluster
}

# AKS prd cluster Verified Module
module "aks_cluster" {
  source              = "./avm-patterns/avm-ptn-aks-production"
  name                = format("%s-%s-cluster", var.service_name, var.environment)
  location            = azurerm_resource_group.cluster_rg.location
  resource_group_name = azurerm_resource_group.cluster_rg.name

  providers = {
    azurerm = azurerm.azure-cluster
  }

  network = {
    name                = data.azurerm_virtual_network.cluster_spoke_vnet.name
    resource_group_name = data.azurerm_virtual_network.cluster_spoke_vnet.resource_group_name
    node_subnet_id      = data.azurerm_subnet.cluster_spoke_aks_node_subnet.id
    pod_cidr            = "10.2.0.0/16" # cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, 2)

  }

  network_policy              = "cilium"
  kubernetes_version          = "1.32"
  private_dns_zone_id         = var.private_dns_zone_id # azurerm_private_dns_zone.aks_private_dns.id
  private_dns_zone_id_enabled = true

  rbac_aad_admin_group_object_ids = [var.entra_admin_group_id]

  default_node_pool_vm_sku = var.cluster_vm_size

  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  node_pools = {
    workload = {
      name                    = "workload"
      vm_size                 = var.cluster_vm_size
      orchestrator_version    = "1.32"
      min_count               = 1
      max_count               = 1
      os_sku                  = "Ubuntu"
      mode                    = "User"
      host_encryption_enabled = false
    }
  }

  tags = {
    environment = var.environment
    owner       = var.service_name
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_link" {
  name                  = format("%s-aks-pe-link-to-spoke", var.environment)
  resource_group_name   = var.lz_network_dns_resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.cluster_spoke_vnet.id
  registration_enabled  = true
  provider              = azurerm.azure-connectivity
}

# Cluster storage accounts

resource "azurerm_storage_account" "sa" {
  for_each                        = toset([format("stgk8treworkspace%s", var.environment), format("stgk8trecore%s", var.environment)])
  name                            = each.key
  resource_group_name             = azurerm_resource_group.cluster_rg.name
  location                        = azurerm_resource_group.cluster_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  provider                        = azurerm.azure-cluster
  public_network_access_enabled   = false
  is_hns_enabled                  = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_can_write_storage" {
  for_each             = azurerm_storage_account.sa
  scope                = each.value.id
  role_definition_name = "Storage Blob Data Contributor"
  provider             = azurerm.azure-cluster
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Role assignments for Azure File Share access
resource "azurerm_role_assignment" "aks_file_share_contributor" {
  for_each             = azurerm_storage_account.sa
  scope                = each.value.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  provider             = azurerm.azure-cluster
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Role assignment for CSI driver to manage file shares and storage account
resource "azurerm_role_assignment" "aks_storage_account_contributor" {
  for_each             = azurerm_storage_account.sa
  scope                = each.value.id
  role_definition_name = "Storage Account Contributor"
  provider             = azurerm.azure-cluster
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

data "azurerm_subnet" "cluster_spoke_private_endpoints_subnet" {
  name                 = "snet-privatelinkendpoints"
  virtual_network_name = data.azurerm_virtual_network.cluster_spoke_vnet.name
  resource_group_name  = data.azurerm_virtual_network.cluster_spoke_vnet.resource_group_name
  provider             = azurerm.azure-cluster
}

data "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

data "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

data "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

data "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

resource "azurerm_private_endpoint" "blob" {
  for_each            = azurerm_storage_account.sa
  name                = format("pe-k8tre-blob-%s-%s", var.environment, each.value.name)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  subnet_id           = data.azurerm_subnet.cluster_spoke_private_endpoints_subnet.id
  provider            = azurerm.azure-cluster

  private_service_connection {
    name                           = format("psc-k8tre-blob-%s-%s", var.environment, each.value.name)
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  tags = {
    "Cost Centre"   = "ICT"
    "Environment"   = "IaC"
    "Service"       = "Network"
    "Service Name"  = "k8tre"
    "Service Owner" = "ICT"
  }

  private_dns_zone_group {
    name = format("pdns-group-k8tre-blob-%s-%s", var.environment, each.value.name)
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.blob.id,
    ]
  }
}

# Private endpoint for Azure File Share
resource "azurerm_private_endpoint" "file" {
  for_each            = azurerm_storage_account.sa
  name                = format("pe-k8tre-file-%s-%s", var.environment, each.value.name)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  subnet_id           = data.azurerm_subnet.cluster_spoke_private_endpoints_subnet.id
  provider            = azurerm.azure-cluster

  private_service_connection {
    name                           = format("psc-k8tre-file-%s-%s", var.environment, each.value.name)
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  tags = {
    "Cost Centre"   = "ICT"
    "Environment"   = "IaC"
    "Service"       = "Network"
    "Service Name"  = "k8tre"
    "Service Owner" = "ICT"
  }

  private_dns_zone_group {
    name = format("pdns-group-k8tre-file-%s-%s", var.environment, each.value.name)
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.file.id,
    ]
  }
}

# Private endpoint for Queue Storage
resource "azurerm_private_endpoint" "queue" {
  for_each            = azurerm_storage_account.sa
  name                = format("pe-k8tre-queue-%s-%s", var.environment, each.value.name)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  subnet_id           = data.azurerm_subnet.cluster_spoke_private_endpoints_subnet.id
  provider            = azurerm.azure-cluster

  private_service_connection {
    name                           = format("psc-k8tre-queue-%s-%s", var.environment, each.value.name)
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  tags = {
    "Cost Centre"   = "ICT"
    "Environment"   = "IaC"
    "Service"       = "Network"
    "Service Name"  = "k8tre"
    "Service Owner" = "ICT"
  }

  private_dns_zone_group {
    name = format("pdns-group-k8tre-queue-%s-%s", var.environment, each.value.name)
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.queue.id,
    ]
  }
}

# Private endpoint for Table Storage
resource "azurerm_private_endpoint" "table" {
  for_each            = azurerm_storage_account.sa
  name                = format("pe-k8tre-table-%s-%s", var.environment, each.value.name)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  subnet_id           = data.azurerm_subnet.cluster_spoke_private_endpoints_subnet.id
  provider            = azurerm.azure-cluster

  private_service_connection {
    name                           = format("psc-k8tre-table-%s-%s", var.environment, each.value.name)
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  tags = {
    "Cost Centre"   = "ICT"
    "Environment"   = "IaC"
    "Service"       = "Network"
    "Service Name"  = "k8tre"
    "Service Owner" = "ICT"
  }

  private_dns_zone_group {
    name = format("pdns-group-k8tre-table-%s-%s", var.environment, each.value.name)
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.table.id,
    ]
  }
}

# Cluster keyvault

resource "azurerm_key_vault" "kv" {
  name                = format("%s-k8tre-kv", var.environment)
  resource_group_name = azurerm_resource_group.cluster_rg.name
  location            = azurerm_resource_group.cluster_rg.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  provider            = azurerm.azure-cluster

  enable_rbac_authorization     = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = false

  # TODO: lockdown to vnet spoke

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_role_assignment" "aks_kv_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  provider             = azurerm.azure-cluster
}
