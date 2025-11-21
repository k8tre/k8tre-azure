variable "mgmt_kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "mgmt_cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}

variable "dev_kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "dev_cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}

variable "stg_kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "stg_cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}

variable "prd_kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "prd_cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}


# variable "stg_kube_host" {
#   description = "The AKS API server host (FQDN)"
#   type        = string
# }

# variable "stg_cluster_ca_certificate" {
#   description = "The base64-encoded cluster CA certificate"
#   type        = string
# }

variable "azure_k8tre_dev_cluster_subscription_id" {
  type        = string
  description = "target cluster sub id"
}

variable "azure_k8tre_mgmt_cluster_subscription_id" {
  type        = string
  description = "infra networking sub id"
}

variable "azure_k8tre_stg_cluster_subscription_id" {
  type        = string
  description = "infra networking sub id"
}

variable "azure_k8tre_prd_cluster_subscription_id" {
  type        = string
  description = "infra networking sub id"
}

variable "SPN_CLIENT_SECRET" {
  description = "SPN account secret"
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
