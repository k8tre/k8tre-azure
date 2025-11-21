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

variable "cluster_name" {
  description = "The name of the AKS cluster"
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
