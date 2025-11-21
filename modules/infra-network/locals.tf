locals {
  environments = var.environments
  subdomains   = var.k8tre_service_domains

  # environment_domains = {
  #   for env in local.environments : env => {
  #     name = "listener-https-${env}"
  #     host_names = [
  #       for sub in local.subdomains :
  #       "${sub}.${env == "prd" ? "" : "${env}."}${var.public_dns_zone_name}"
  #     ]
  #   }
  # }

  environment_domains = {
    for env in local.environments : env => {
      name = "listener-https-${env}"
      host_names = [
        "${env == "prd" ? "" : "${env}."}${var.public_dns_zone_name}",
        "*.${env == "prd" ? "" : "${env}."}${var.public_dns_zone_name}"
      ]
    }
  }

}
