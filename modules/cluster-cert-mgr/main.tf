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

data "azurerm_dns_zone" "k8tre_public_zone" {
  name                = var.k8tre_public_zone_name
  resource_group_name = "rg-kare-con-uks-dns"
  provider            = azurerm.azure-connectivity
}

resource "azurerm_user_assigned_identity" "certs_mgr_id" {
  name                = format("%s-certs-mgr-managed-identity", var.cluster_name)
  location            = "uksouth"
  resource_group_name = var.cluster_resource_group_name
  provider            = azurerm.azure
}

resource "azurerm_federated_identity_credential" "cert_mgr_cred" {
  name                = format("%s-fed-cred", var.cluster_name)
  resource_group_name = var.cluster_resource_group_name
  parent_id           = azurerm_user_assigned_identity.certs_mgr_id.id

  issuer   = var.oidc_issuer_url
  subject  = "system:serviceaccount:cert-manager:cert-manager"
  audience = ["api://AzureADTokenExchange"]
  provider = azurerm.azure
}

resource "azurerm_role_assignment" "cert_dns_role" {
  scope                = data.azurerm_dns_zone.k8tre_public_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.certs_mgr_id.principal_id
  provider             = azurerm.azure
}

