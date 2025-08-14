
output "kube_host" {
  value     = module.aks_cluster.kube_config[0].host
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks_cluster.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "resource_group_name" {
  value = module.aks_cluster.aks_resource_group_name
}

output "fq_cluster_name" {
  value = module.aks_cluster.aks_name
}

output "environment" {
  value = var.environment
}

output "client_certificate" {
  value     = module.aks_cluster.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks_cluster.kube_config[0].client_key
  sensitive = true
}

output "kube_config" {
  value     = module.aks_cluster.kube_config
  sensitive = true
}

output "oidc_issuer_url" {
  value = module.aks_cluster.oidc_issuer_url
}
