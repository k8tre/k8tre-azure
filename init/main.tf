terraform {
  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  alias           = "azure-k8sman"
  subscription_id = var.azure_k8tre_mgmt_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-dev"
  subscription_id = var.azure_k8tre_dev_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-staging"
  subscription_id = var.azure_k8tre_stg_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-connectivity"
  subscription_id = var.azure_k8tre_connectivity_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-management"
  subscription_id = var.azure_k8tre_mgmt_subscription_id
  features {}
}

module "azure_infrastructure" {
  source       = "../"
  region       = var.region
  cluster_name = var.cluster_name
  providers = {
    azurerm.azure-k8sman       = azurerm.azure-k8sman
    azurerm.azure-dev          = azurerm.azure-dev
    azurerm.azure-connectivity = azurerm.azure-connectivity
    azurerm.azure-staging      = azurerm.azure-staging
    azurerm.azure-management   = azurerm.azure-management
  }
}

