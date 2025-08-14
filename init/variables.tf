variable "region" {
  type        = string
  description = "infrastructure region"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "k8tre"
}

variable "azure_k8tre_mgmt_cluster_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_k8tre_dev_cluster_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_k8tre_stg_cluster_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_k8tre_connectivity_cluster_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_k8tre_mgmt_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}
