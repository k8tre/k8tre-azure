locals {
    # Service Principal w/ Owner role on Landing Zone
    # Client secret must be set in environment variable SPN_CLIENT_SECRET
    spn_client_id                                    = "b78f544b-ede0-4ed2-8c2c-0d7474acef8c"
    region                                           = "uksouth"
    cluster_name                                     = "k8tre"
    azure_k8tre_mgmt_cluster_subscription_id         = "6810437b-9cbb-40f4-89d8-a9b98f3de028"
    azure_k8tre_dev_cluster_subscription_id          = "02b2c397-edb6-476f-b3a4-aa63e0621c53"
    azure_tenant_id                                  = "30a82846-a29e-4b6b-af27-9b19418ee1b3"
    azure_k8tre_connectivity_subscription_id         = "443fc06f-050e-4794-83d8-eaeee691d453"
    azure_k8tre_stg_cluster_subscription_id          = "4e83168f-6204-4255-b1c0-9042c6fe5afd"
    azure_k8tre_mgmt_subscription_id                 = "db3e5dae-c030-44df-8205-c512d0195e0e"
    azure_k8tre_iac_subscription_id                  = "d72c48dc-0c7f-4fac-8ce7-fc451e32632b"
    azure_k8tre_prd_cluster_subscription_id          = "d466592d-46fb-432e-9b10-5fc47c2c5cc9"

    # Entra Security Group must exist before mgmt cluster deployment
    entra_admin_group_id                             = "8495e6fa-3c66-403b-abfe-227062b5d9d0"
 
    # infra-network
    internal_dns_zone_name                           = "k8tre.internal"
    public_dns_zone_name                             = "karectl.org"
    k8tre_service_domains                            = ["jupyter", "opal", "keycloak"]
    environments                                     = ["dev", "stg", "prd"]

    lz_iac_core_resource_group_name                  = "rg-kare-iac-core"
    lz_iac_spoke_vnet_name                           = "vnet-iac-spoke-uks"

    lz_network_resource_group_name                   = "rg-kare-con-uks-network"
    lz_network_dns_resource_group_name               = "rg-kare-con-uks-dns"
    lz_hub_vnet_name                                 = "vnet-kare-con-uks-hub"

    app_gateway_ssl_certificate_filename             = "certificate-dev-stg-prd.pfx"
    app_gateway_ssl_certificate_passphrase           = "testtesttest" # Note: Do not hardcode this, set via environment variable

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
            resource_group_name   = "rg-kare-iac-core"
            storage_account_name  = "stkareiacstate"
            container_name        = "tfstate"
            key                   = "${path_relative_to_include()}/k8tre.tfstate"
        }
    }
EOF

}