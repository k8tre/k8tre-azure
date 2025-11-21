locals {
  environments = var.environments

  environment_domains = {
    for env in local.environments : env => {
      name       = "tls-${env}"
      subject    = env == "prd" ? var.public_dns_zone_name : "${env}.${var.public_dns_zone_name}"
      host_names = env == "prd" ? ["*.${var.public_dns_zone_name}"] : ["${env}.${var.public_dns_zone_name}", "*.${env}.${var.public_dns_zone_name}"]
    }
  }
}
