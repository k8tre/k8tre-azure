variable "region" {
  type        = string
  description = "infrastructure region"
}

variable "tenant_id" {
  type        = string
  description = "infrastructure region"
}

variable "azure_k8tre_connectivity_subscription_id" {
  type        = string
  description = "Subscription ID for Azure landing zone hub networking resources"
}

variable "environments" {
  type        = list(string)
  description = "names for the environments to be created, e.g. dev, stg, prd"
  default     = []
}

variable "common_tags" {
  description = "Resource tags for Azure policy rules"
  type        = map(string)
  default     = {}
}

variable "public_dns_zone_name" {
  type        = string
  description = "The public DNS zone name for an organisations version of K8TRE, e.g. karectl.org"
}

variable "spn_client_id" {
  type        = string
  description = "Service Principal Client"
}

variable "SPN_CLIENT_SECRET" {
  description = "SPN account secret"
  type        = string
}


