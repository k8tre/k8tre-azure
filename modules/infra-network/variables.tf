variable "region" {
  type        = string
  description = "infrastructure region"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "k8tre"
}

variable "azure_k8tre_connectivity_subscription_id" {
  type        = string
  description = "Subscription ID for Azure landing zone hub networking resources"
}

variable "azure_k8tre_iac_subscription_id" {
  type        = string
  description = "Subscription ID for Landing Zone IaC resources"
}

variable "environments" {
  type        = list(string)
  description = "names for the environments to be created, e.g. dev, stg, prd"
  default     = []
}

variable "k8tre_service_domains" {
  type        = list(string)
  description = "service domains for k8tre services that require public ingress, e.g. jupyter, opal, keycloak"
  default     = []
}

variable "public_dns_zone_name" {
  type        = string
  description = "The public DNS zone name for an organisations version of K8TRE, e.g. karectl.org"
}

variable "internal_dns_zone_name" {
  type        = string
  description = "The internal DNS zone for K8TRE e.g. k8tre.internal"
}

variable "common_tags" {
  description = "Resource tags for Azure policy rules"
  type        = map(string)
  default     = {}
}

variable "lz_hub_vnet_name" {
  type        = string
  description = "Name of the landing zone hub VNet"
}

variable "lz_network_resource_group_name" {
  type        = string
  description = "Name of the resource group for the landing zone hub networking resources"
}

variable "lz_iac_spoke_vnet_name" {
  type        = string
  description = "Name of the landing zone spoke VNet for IaC resources"
}

variable "lz_iac_core_resource_group_name" {
  type        = string
  description = "Name of the resource group for IaC core resources"
}

variable "lz_network_dns_resource_group_name" {
  type        = string
  description = "Name of the resource group for the landing zone hub DNS resources"
}
