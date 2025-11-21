variable "cluster_subscription_id" {
  type        = string
  description = "target cluster subscription id"
}

variable "azure_k8tre_connectivity_subscription_id" {
  type        = string
  description = "target cluster subscription id"
}


variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "oidc_issuer_url of k8s cluster"
  type        = string
}

variable "cluster_resource_group_name" {
  description = "The resource group name of the AKS cluster"
  type        = string
}

variable "k8tre_public_zone_name" {
  description = "Name of public DNS zone"
  type        = string
}



