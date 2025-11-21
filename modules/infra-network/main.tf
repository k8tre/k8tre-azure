terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
  required_version = ">= 1.7.0, < 2.0.0"
}

provider "azurerm" {
  alias           = "azure-connectivity"
  subscription_id = var.azure_k8tre_connectivity_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-iac-spoke"
  subscription_id = var.azure_k8tre_iac_subscription_id
  features {}
}

data "azurerm_virtual_network" "iac_vnet" {
  name                = var.lz_iac_spoke_vnet_name
  resource_group_name = var.lz_iac_core_resource_group_name
  provider            = azurerm.azure-iac-spoke
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.lz_hub_vnet_name
  resource_group_name = var.lz_network_resource_group_name
  provider            = azurerm.azure-connectivity
}

resource "azurerm_private_dns_zone" "pe_private_dns" {
  name                = format("privatelink.%s.azmk8s.io", var.region)
  resource_group_name = var.lz_network_dns_resource_group_name
  provider            = azurerm.azure-connectivity
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_link" {
  name                  = "pe_uksouth_link-to-hub"
  resource_group_name   = var.lz_network_dns_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pe_private_dns.name
  virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
  provider              = azurerm.azure-connectivity
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "iac_link" {
  name                  = "link-to-iac-spoke"
  resource_group_name   = var.lz_network_dns_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pe_private_dns.name
  virtual_network_id    = data.azurerm_virtual_network.iac_vnet.id
  provider              = azurerm.azure-connectivity
  registration_enabled  = false
}


# External App Gateway for KARECTL environment


resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-karectl"
  location            = "uksouth"
  resource_group_name = var.lz_network_resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
  sku_tier          = "Regional"

  domain_name_label = "karectl-appgw"
  provider          = azurerm.azure-connectivity
}

# resource "azurerm_dns_a_record" "root_record" {
#   name                = "@"
#   zone_name           = "karectl.org"
#   resource_group_name = "rg-kare-con-uks-dns"
#   ttl                 = 300
#   records             = [azurerm_public_ip.appgw_pip.ip_address]
#   provider            = azurerm.azure-connectivity
# }

# resource "azurerm_dns_a_record" "stg_record" {
#   name                = "stg"
#   zone_name           = "karectl.org"
#   resource_group_name = "rg-kare-con-uks-dns"
#   ttl                 = 300
#   records             = [azurerm_public_ip.appgw_pip.ip_address]
#   provider            = azurerm.azure-connectivity
# }

# resource "azurerm_dns_a_record" "dev_record" {
#   name                = "dev"
#   zone_name           = "karectl.org"
#   resource_group_name = "rg-kare-con-uks-dns"
#   ttl                 = 300
#   records             = [azurerm_public_ip.appgw_pip.ip_address]
#   provider            = azurerm.azure-connectivity
# }



data "azurerm_resource_group" "rg" {
  name     = var.lz_network_resource_group_name
  provider = azurerm.azure-connectivity
}

data "azurerm_subnet" "subnet" {
  name                 = "PublicGatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.hub_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  provider             = azurerm.azure-connectivity
}

data "azurerm_key_vault" "certs_kv" {
  name                = "kv-kare-cert-store"
  resource_group_name = "rg-kare-con-uks-certs"
  provider            = azurerm.azure-connectivity
}

data "azurerm_key_vault_secret" "cluster_pfx_secrets" {
  for_each     = local.environment_domains
  name         = "tls-${each.key}-pfx"
  key_vault_id = data.azurerm_key_vault.certs_kv.id
  provider     = azurerm.azure-connectivity
}

resource "azurerm_user_assigned_identity" "appgw_identity" {
  name                = "appgw-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  provider            = azurerm.azure-connectivity
}

resource "azurerm_role_assignment" "appgw_kv_secret_reader" {
  scope                = data.azurerm_key_vault.certs_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw_identity.principal_id
  provider             = azurerm.azure-connectivity
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-karectl"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  provider            = azurerm.azure-connectivity

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw_identity.id]
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.subnet.id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGwFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  dynamic "ssl_certificate" {
    for_each = local.environment_domains

    content {
      name                = "ssl-cert-${ssl_certificate.key}"
      key_vault_secret_id = data.azurerm_key_vault_secret.cluster_pfx_secrets[ssl_certificate.key].versionless_id
    }
  }

  # Listeners
  dynamic "http_listener" {
    for_each = local.environment_domains

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "appGwFrontendIP"
      frontend_port_name             = "https"
      protocol                       = "Https"
      host_names                     = http_listener.value.host_names
      ssl_certificate_name           = "ssl-cert-${http_listener.key}"
    }
  }

  # routing rules

  dynamic "request_routing_rule" {
    for_each = local.environment_domains

    content {
      name                       = "rule-${request_routing_rule.key}"
      rule_type                  = "Basic"
      priority                   = index(local.environments, request_routing_rule.key) + 1
      http_listener_name         = "listener-https-${request_routing_rule.key}"
      backend_address_pool_name  = "backendpool-${request_routing_rule.key}"
      backend_http_settings_name = "https-settings-${request_routing_rule.key}"
      # rewrite_rule_set_name      = "rewrite-${request_routing_rule.key}"
    }

  }

  # backend pools for cluster gateways

  dynamic "backend_address_pool" {
    for_each = local.environment_domains

    content {
      name  = "backendpool-${backend_address_pool.key}"
      fqdns = ["gw.${backend_address_pool.key == "prd" ? "" : "${backend_address_pool.key}."}${var.public_dns_zone_name}"]
    }

  }

  # backend http settings

  dynamic "probe" {
    for_each = local.environment_domains

    content {
      name                                      = "health-probe-${probe.key}"
      protocol                                  = "Https"
      host                                      = "gw.${probe.key == "prd" ? "" : "${probe.key}."}${var.public_dns_zone_name}"
      path                                      = "/"
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = false
    }

  }

  dynamic "backend_http_settings" {
    for_each = local.environment_domains

    content {
      name                                = "https-settings-${backend_http_settings.key}"
      port                                = 443
      protocol                            = "Https"
      cookie_based_affinity               = "Enabled"
      request_timeout                     = 30
      pick_host_name_from_backend_address = false
      probe_name                          = "health-probe-${backend_http_settings.key}"
    }
  }

  # dynamic "rewrite_rule_set" {
  #   for_each = local.environment_domains

  #   content {
  #     name = "rewrite-${rewrite_rule_set.key}"

  #     rewrite_rule {
  #       name          = "rewrite-host-jupyter"
  #       rule_sequence = 100
  #       condition {
  #         variable    = "http_req_Host"
  #         pattern     = (rewrite_rule_set.key == "prd" ? "jupyter.karectl.dev" : "jupyter.${rewrite_rule_set.key}.karectl.dev")
  #         ignore_case = true
  #       }
  #       request_header_configuration {
  #         header_name  = "Host"
  #         header_value = (rewrite_rule_set.key == "prd" ? "jupyter.k8tre.internal" : "jupyter.${rewrite_rule_set.key}.k8tre.internal")
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-host-opal"
  #       rule_sequence = 110
  #       condition {
  #         variable    = "http_req_Host"
  #         pattern     = (rewrite_rule_set.key == "prd" ? "opal.karectl.dev" : "opal.${rewrite_rule_set.key}.karectl.dev")
  #         ignore_case = true
  #       }
  #       request_header_configuration {
  #         header_name  = "Host"
  #         header_value = (rewrite_rule_set.key == "prd" ? "opal.k8tre.internal" : "opal.${rewrite_rule_set.key}.k8tre.internal")
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-host-keycloak"
  #       rule_sequence = 120
  #       condition {
  #         variable    = "http_req_Host"
  #         pattern     = (rewrite_rule_set.key == "prd" ? "keycloak.karectl.dev" : "keycloak.${rewrite_rule_set.key}.karectl.dev")
  #         ignore_case = true
  #       }
  #       request_header_configuration {
  #         header_name  = "Host"
  #         header_value = (rewrite_rule_set.key == "prd" ? "keycloak.k8tre.internal" : "keycloak.${rewrite_rule_set.key}.k8tre.internal")
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-location-keycloak"
  #       rule_sequence = 200
  #       condition {
  #         variable = "http_resp_Location"
  #         pattern = (
  #           rewrite_rule_set.key == "prd"
  #           ? "(https?):\\/\\/.*keycloak\\.k8tre\\.internal(.*)$"
  #           : "(https?):\\/\\/.*keycloak\\.${rewrite_rule_set.key}\\.k8tre\\.internal(.*)$"
  #         )
  #       }
  #       response_header_configuration {
  #         header_name = "Location"
  #         header_value = (
  #           rewrite_rule_set.key == "prd"
  #           ? "{http_resp_Location_1}://keycloak.karectl.dev{http_resp_Location_2}"
  #           : "{http_resp_Location_1}://keycloak.${rewrite_rule_set.key}.karectl.dev{http_resp_Location_2}"
  #         )
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-location-jupyter"
  #       rule_sequence = 210
  #       condition {
  #         variable = "http_resp_Location"
  #         pattern = (
  #           rewrite_rule_set.key == "prd"
  #           ? "^(.*)jupyter\\.k8tre\\.internal(.*)$"
  #           : "^(.*)jupyter\\.${rewrite_rule_set.key}\\.k8tre\\.internal(.*)$"
  #         )
  #       }
  #       response_header_configuration {
  #         header_name = "Location"
  #         header_value = (
  #           rewrite_rule_set.key == "prd"
  #           ? "{http_resp_Location_1}jupyter.karectl.dev{http_resp_Location_2}"
  #           : "{http_resp_Location_1}jupyter.${rewrite_rule_set.key}.karectl.dev{http_resp_Location_2}"
  #         )
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-location-redirect-uri"
  #       rule_sequence = 220
  #       condition {
  #         variable = "http_resp_Location"
  #         pattern = (
  #           rewrite_rule_set.key == "prd"
  #           ? "(.*)(redirect_uri=https%3A%2F%2F)jupyter\\.k8tre\\.internal(.*)$"
  #           : "(.*)(redirect_uri=https%3A%2F%2F)jupyter\\.${rewrite_rule_set.key}\\.k8tre\\.internal(.*)$"
  #         )
  #       }
  #       response_header_configuration {
  #         header_name = "Location"
  #         header_value = (
  #           rewrite_rule_set.key == "prd"
  #           ? "{http_resp_Location_1}{http_resp_Location_2}jupyter.karectl.dev{http_resp_Location_3}"
  #           : "{http_resp_Location_1}{http_resp_Location_2}jupyter.${rewrite_rule_set.key}.karectl.dev{http_resp_Location_3}"
  #         )
  #       }
  #     }

  #     rewrite_rule {
  #       name          = "rewrite-request-uri"
  #       rule_sequence = 300
  #       condition {
  #         variable = "var_request_uri"
  #         pattern = (
  #           rewrite_rule_set.key == "prd"
  #           ? "^([^?]*\\?)(.*)redirect_uri=https%3A%2F%2Fjupyter\\.karectl\\.dev%2Fhub%2Foauth_callback(.*)$"
  #           : "^([^?]*\\?)(.*)redirect_uri=https%3A%2F%2Fjupyter\\.${rewrite_rule_set.key}\\.karectl\\.dev%2Fhub%2Foauth_callback(.*)$"
  #         )
  #       }
  #       url {
  #         query_string = (
  #           rewrite_rule_set.key == "prd"
  #           ? "{var_request_uri_2}redirect_uri=https%3A%2F%2Fjupyter.k8tre.internal%2Fhub%2Foauth_callback{var_request_uri_3}"
  #           : "{var_request_uri_2}redirect_uri=https%3A%2F%2Fjupyter.${rewrite_rule_set.key}.k8tre.internal%2Fhub%2Foauth_callback{var_request_uri_3}"
  #         )
  #         components = "query_string_only"
  #       }
  #     }
  #   }
  # }

  tags = var.common_tags

}
