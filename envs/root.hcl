locals {
    # Service Principal w/ Owner role on Landing Zone
    # Client secret must be set in environment variable SPN_CLIENT_SECRET
    spn_client_id                                    = ""
    region                                           = ""
    cluster_name                                     = ""
    azure_k8tre_mgmt_cluster_subscription_id         = ""
    azure_k8tre_dev_cluster_subscription_id          = ""
    azure_tenant_id                                  = ""
    azure_k8tre_connectivity_subscription_id         = ""
    azure_k8tre_stg_cluster_subscription_id          = ""
    azure_k8tre_mgmt_subscription_id                 = ""
    azure_k8tre_iac_subscription_id                  = ""
    azure_k8tre_prd_cluster_subscription_id          = ""

    # Entra Security Group must exist before mgmt cluster deployment
    entra_admin_group_id                             = ""
 
    # infra-network
    internal_dns_zone_name                           = ""
    public_dns_zone_name                             = ""
    k8tre_service_domains                            = ["jupyter", "opal", "keycloak"]
    environments                                     = ["dev", "stg", "prd"]

    lz_iac_core_resource_group_name                  = ""
    lz_iac_spoke_vnet_name                           = ""

    lz_network_resource_group_name                   = ""
    lz_network_dns_resource_group_name               = ""
    lz_hub_vnet_name                                 = ""

    app_gateway_ssl_certificate_filename             = ""
    app_gateway_ssl_certificate_passphrase           = ""

    common_tags = {
        "Cost Centre"   = "ICT"
        "Environment"   = "IaC"
        "Service Owner" = "ICT"
        "Service Name"  = "k8tre"
        "Service"       = "k8tre"
        "ServiceName"   = "k8tre"
    }

}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    terraform {
        backend "azurerm" {
            resource_group_name   = ""
            storage_account_name  = ""
            container_name        = "tfstate"
            key                   = "${path_relative_to_include()}/k8tre.tfstate"
        }
    }
EOF

}