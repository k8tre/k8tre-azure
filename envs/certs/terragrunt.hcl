include "root" {
  path = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "../../modules/infra-certs"
}

inputs = {
  region       = include.root.locals.region
  tenant_id = include.root.locals.azure_tenant_id
  azure_k8tre_connectivity_subscription_id = include.root.locals.azure_k8tre_connectivity_subscription_id
  public_dns_zone_name = include.root.locals.public_dns_zone_name
  environments = include.root.locals.environments
  common_tags = include.root.locals.common_tags
  spn_client_id = include.root.locals.spn_client_id
}