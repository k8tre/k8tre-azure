variable "k8tre_cluster_subscription_id" {
  type        = string
  description = "sub id"
}


variable "kube_host" {
  description = "The AKS API server host (FQDN)"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The base64-encoded cluster CA certificate"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name of the AKS cluster"
  type        = string
}

variable "fq_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "client_certificate" {
  description = "The resource group name of the AKS cluster"
  type        = string
}

variable "client_key" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "SPN_CLIENT_SECRET" {
  description = "SPN account secret"
  type        = string
}

variable "entra_admin_group_id" {
  description = "Identifier of the Entra admin group that will be granted admin access to ArgoCD"
  type        = string
}

variable "cluster_tenant_id" {
  description = "Identifier of the Entra tenant where the cluster is deployed"
  type        = string
}

variable "spn_client_id" {
  description = "Identifier of the Service Principal that will be used to authenticate to the cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "oidc issuer url of argo mgmt cluster"
  type        = string
}




# variable "argo_entra_application_id" {
#   description = "Identifier of the Entra application that will be granted access to ArgoCD"
#   type        = string
# }
