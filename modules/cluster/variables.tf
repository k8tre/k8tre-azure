variable "environment" {
  description = "The name of target cluster environment"
  type        = string
}

variable "region" {
  type        = string
  description = "infrastructure region"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant id"
}

variable "service_name" {
  type        = string
  description = "Name of the service"
  default     = "k8tre"
}

variable "private_dns_zone_id" {
  type        = string
  description = "private dns id"
}

variable "private_dns_zone_name" {
  type        = string
  description = "private dns name"
}

variable "k8tre_cluster_subscription_id" {
  type        = string
  description = "target cluster sub id"
}

variable "k8tre_connectivity_subscription_id" {
  type        = string
  description = "infra networking sub id"
}

variable "entra_admin_group_id" {
  type        = string
  description = "Entra k8s admin group id"
}

variable "lz_network_dns_resource_group_name" {
  type        = string
  description = "Resource group name for the landing zone network DNS resources"
}

variable "cluster_vm_size" {
  type        = string
  description = "VM size for the cluster nodes"
}


