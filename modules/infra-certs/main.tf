terraform {

  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~>2.32"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }

    external = {
      source  = "hashicorp/external"
      version = "~>2.3"
    }

  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_k8tre_connectivity_subscription_id
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"

}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "public_certificates" {
  location = "uksouth"
  name     = "rg-kare-con-uks-certs"
  # provider = azurerm.azure-connectivity
  tags = var.common_tags
}

data "azuread_service_principal" "cicd_spn" {
  client_id = var.spn_client_id
}

resource "azurerm_role_assignment" "terraform_kv_secrets_officer" {
  scope                = module.keyvault.resource_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [module.keyvault]
}

module "keyvault" {

  location                      = var.region
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.10.1"
  name                          = "kv-kare-cert-store"
  resource_group_name           = azurerm_resource_group.public_certificates.name
  tenant_id                     = var.tenant_id
  enable_telemetry              = false
  sku_name                      = "standard"
  public_network_access_enabled = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = var.common_tags

  #   private_endpoints = {
  #     primary = {
  #       private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.vaultcore.id]
  #       subnet_resource_id            = azurerm_subnet.this.id
  #     }
  #   }

}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  email_address   = "m.harding@lancaster.ac.uk"
  account_key_pem = tls_private_key.private_key.private_key_pem
}

resource "acme_certificate" "cert" {
  for_each                     = local.environment_domains
  account_key_pem              = acme_registration.reg.account_key_pem
  min_days_remaining           = 33
  disable_complete_propagation = true

  common_name               = each.value.subject
  subject_alternative_names = each.value.host_names

  dns_challenge {
    provider = "azuredns"
    config = {
      AZURE_AUTH_METHOD    = "cli"
      AZURE_RESOURCE_GROUP = "rg-kare-con-uks-dns"
      AZURE_ZONE_NAME      = var.public_dns_zone_name
      AZURE_TENANT_ID      = var.tenant_id
    }
  }
}

resource "time_sleep" "wait_for_kv_role" {
  depends_on      = [azurerm_role_assignment.terraform_kv_secrets_officer]
  create_duration = "30s"
}

resource "azurerm_key_vault_secret" "cert_pem" {
  for_each     = local.environment_domains
  name         = "${each.value.name}-cert"
  value        = acme_certificate.cert[each.key].certificate_pem
  key_vault_id = module.keyvault.resource_id
  depends_on   = [time_sleep.wait_for_kv_role]
}

resource "azurerm_key_vault_secret" "cert_key" {
  for_each     = local.environment_domains
  name         = "${each.value.name}-key"
  value        = acme_certificate.cert[each.key].private_key_pem
  key_vault_id = module.keyvault.resource_id
  depends_on   = [time_sleep.wait_for_kv_role]
}

data "external" "make_pfx" {
  for_each = local.environment_domains

  program = ["bash", "${path.module}/scripts/make-unencrypted-pfx.sh"]

  query = {
    CERT_PEM = acme_certificate.cert[each.key].certificate_pem
    KEY_PEM  = acme_certificate.cert[each.key].private_key_pem
  }
}

resource "azurerm_key_vault_secret" "pfx" {
  for_each     = local.environment_domains
  name         = "${each.value.name}-pfx"
  value        = data.external.make_pfx[each.key].result.pfx_b64
  key_vault_id = module.keyvault.resource_id
}


