include "root" {
  path = find_in_parent_folders("root.hcl")
  expose  = true
}

locals {
  environment = "stg"
}

terraform {
  source = "../../../modules/cluster"
}

dependency "infra_network" {
  config_path = "../../network"
  mock_outputs = {
    private_dns_zone_id   = "/subscriptions/12345678-90ab-cdef-1234-567890abcdef/resourceGroups/my-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.uksouth.azmk8s.io"
    private_dns_zone_name = "privatelink.uksouth.azmk8s.io"
 }

  mock_outputs_allowed_terraform_commands = ["plan", "refresh"]
}

inputs = {
  region                                    = include.root.locals.region
  environment                               = locals.environment
  service_name                              = include.root.locals.cluster_name # change
  cluster_name                              = include.root.locals.cluster_name
  k8tre_cluster_subscription_id             = include.root.locals.azure_k8tre_stg_cluster_subscription_id
  k8tre_connectivity_subscription_id        = include.root.locals.azure_k8tre_connectivity_subscription_id
  private_dns_zone_id                       = dependency.infra_network.outputs.private_dns_zone_id
  private_dns_zone_name                     = dependency.infra_network.outputs.private_dns_zone_name
  tenant_id                                 = include.root.locals.azure_tenant_id

  entra_admin_group_id                      = include.root.locals.entra_admin_group_id
  lz_network_dns_resource_group_name        = include.root.locals.lz_network_dns_resource_group_name
}



  


