variable "cluster_subscription_id" {
  type        = string
  description = "target cluster subscription id"
}

variable "azure_k8tre_connectivity_subscription_id" {
  type        = string
  description = "target cluster subscription id"
}

variable "kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}

variable "SPN_CLIENT_SECRET" {
  description = "SPN account secret"
  type        = string
}

variable "cluster_resource_group_name" {
  description = "The resource group name of the AKS cluster"
  type        = string
}

variable "fq_cluster_name" {
  description = "The fully qualified cluster name (FQDN) of the AKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "cluster_domain_name" {
  description = "The domain name for the cluster DNS"
  type        = string
}

variable "oidc_issuer_url" {
  description = "oidc_issuer_url of k8s cluster"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "spn_client_id" {
  description = "Service Principal Client ID"
  type        = string
}

variable "lz_hub_vnet_name" {
  type        = string
  description = "Name of the landing zone hub VNet"
}

variable "lz_network_resource_group_name" {
  type        = string
  description = "Name of the resource group for the landing zone hub networking resources"
}

variable "lz_network_dns_resource_group_name" {
  type        = string
  description = "Name of the resource group for the landing zone hub DNS resources"
}
