include "root" {
  path = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "../../modules/infra-network"
}

inputs = {
  region       = include.root.locals.region
  cluster_name  = include.root.locals.cluster_name
  azure_k8tre_connectivity_subscription_id = include.root.locals.azure_k8tre_connectivity_subscription_id
  internal_dns_zone_name = include.root.locals.internal_dns_zone_name
  public_dns_zone_name = include.root.locals.public_dns_zone_name
  k8tre_service_domains = include.root.locals.k8tre_service_domains
  environments = include.root.locals.environments

  common_tags = merge(include.root.locals.common_tags, { 
    "Service"      = "App Gateway"
  })

  lz_hub_vnet_name = include.root.locals.lz_hub_vnet_name
  lz_network_resource_group_name = include.root.locals.lz_network_resource_group_name
  lz_iac_core_resource_group_name = include.root.locals.lz_iac_core_resource_group_name
  lz_iac_spoke_vnet_name = include.root.locals.lz_iac_spoke_vnet_name
  lz_network_dns_resource_group_name = include.root.locals.lz_network_dns_resource_group_name
  azure_k8tre_iac_subscription_id = include.root.locals.azure_k8tre_iac_subscription_id

}