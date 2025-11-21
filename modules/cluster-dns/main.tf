terraform {

  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "azurerm" {
  alias           = "azure"
  subscription_id = var.cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-connectivity"
  subscription_id = var.azure_k8tre_connectivity_subscription_id
  features {}
}

provider "kubernetes" {
  host                   = var.kube_host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = ["get-token", "--login", "spn",
      "--client-id", "${var.spn_client_id}",
      "--client-secret", "${var.SPN_CLIENT_SECRET}",
      "--tenant-id", "${var.azure_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.kube_host
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = ["get-token", "--login", "spn",
        "--client-id", "${var.spn_client_id}",
        "--client-secret", "${var.SPN_CLIENT_SECRET}",
        "--tenant-id", "${var.azure_tenant_id}",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}

# data "azurerm_kubernetes_cluster" "aks" {
#   name                = var.fq_cluster_name
#   resource_group_name = var.cluster_resource_group_name
#   provider            = azurerm.azure
# }

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.lz_hub_vnet_name
  resource_group_name = var.lz_network_resource_group_name
  provider            = azurerm.azure-connectivity
}

resource "azurerm_user_assigned_identity" "externaldns" {
  name                = format("%s-externaldns-uami", var.cluster_name)
  location            = "uksouth"
  resource_group_name = var.cluster_resource_group_name
  provider            = azurerm.azure
}

resource "azurerm_federated_identity_credential" "externaldns" {
  name                = "externaldns-federated"
  resource_group_name = var.cluster_resource_group_name
  parent_id           = azurerm_user_assigned_identity.externaldns.id

  issuer   = var.oidc_issuer_url # data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject  = "system:serviceaccount:externaldns:externaldns"
  audience = ["api://AzureADTokenExchange"]
  provider = azurerm.azure
}

resource "azurerm_private_dns_zone" "dns" {
  name                = var.cluster_domain_name
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

resource "azurerm_private_dns_zone_virtual_network_link" "externaldns_link" {
  name                  = format("%s-external-dns-link", var.cluster_name)
  resource_group_name   = azurerm_private_dns_zone.dns.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
  provider              = azurerm.azure-connectivity
  registration_enabled  = false
  depends_on            = [azurerm_private_dns_zone.dns]
}

resource "azurerm_role_assignment" "externaldns_dns" {
  scope                = azurerm_private_dns_zone.dns.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.externaldns.principal_id
  provider             = azurerm.azure
}

# resource "helm_release" "externaldns" {
#   name             = "externaldns"
#   repository       = "https://charts.bitnami.com/bitnami"
#   chart            = "external-dns"
#   namespace        = "externaldns"
#   create_namespace = true
#   version          = "6.32.0"
#   values = [<<EOF
#           provider: azure-private-dns
#           azure:
#             resourceGroup: "${azurerm_private_dns_zone.dns.resource_group_name}"
#             subscriptionId: "443fc06f-050e-4794-83d8-eaeee691d453"
#             tenantId: "30a82846-a29e-4b6b-af27-9b19418ee1b3"
#             useWorkloadIdentityExtension: true
#           domainFilters:
#             - ${var.cluster_domain_name}
#           policy: sync
#           txtOwnerId: externaldns
#           podLabels:
#             azure.workload.identity/use: "true"
#           serviceAccount:
#             create: true
#             name: externaldns
#             annotations:
#               azure.workload.identity/client-id: "${azurerm_user_assigned_identity.externaldns.client_id}"
#           EOF
#   ]
# }
