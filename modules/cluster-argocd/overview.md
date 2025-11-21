<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) (1.0.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.26.0)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (~> 2.23)

## Resources

The following resources are used by this module:

- [argocd_cluster.external](https://registry.terraform.io/providers/0011blindmice/argocd/1.0.3/docs/resources/cluster) (resource)
- [argocd_cluster.stg_external](https://registry.terraform.io/providers/0011blindmice/argocd/1.0.3/docs/resources/cluster) (resource)
- [kubernetes_cluster_role_binding.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) (resource)
- [kubernetes_cluster_role_binding.stg_argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) (resource)
- [kubernetes_secret_v1.argocd_gen_sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)
- [kubernetes_secret_v1.stg_argocd_gen_sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)
- [kubernetes_service_account_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) (resource)
- [kubernetes_service_account_v1.stg_argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) (resource)
- [kubernetes_secret_v1.argocd_sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) (data source)
- [kubernetes_secret_v1.stg_argocd_sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_SPN_CLIENT_SECRET"></a> [SPN\_CLIENT\_SECRET](#input\_SPN\_CLIENT\_SECRET)

Description: SPN account secret

Type: `string`

### <a name="input_argocd_admin_password"></a> [argocd\_admin\_password](#input\_argocd\_admin\_password)

Description: The ArgoCD admin password

Type: `string`

### <a name="input_azure_k8tre_dev_cluster_subscription_id"></a> [azure\_k8tre\_dev\_cluster\_subscription\_id](#input\_azure\_k8tre\_dev\_cluster\_subscription\_id)

Description: target cluster sub id

Type: `string`

### <a name="input_azure_k8tre_mgmt_cluster_subscription_id"></a> [azure\_k8tre\_mgmt\_cluster\_subscription\_id](#input\_azure\_k8tre\_mgmt\_cluster\_subscription\_id)

Description: infra networking sub id

Type: `string`

### <a name="input_azure_k8tre_stg_cluster_subscription_id"></a> [azure\_k8tre\_stg\_cluster\_subscription\_id](#input\_azure\_k8tre\_stg\_cluster\_subscription\_id)

Description: infra networking sub id

Type: `string`

### <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id)

Description: Azure tenant ID

Type: `string`

### <a name="input_dev_cluster_ca_certificate"></a> [dev\_cluster\_ca\_certificate](#input\_dev\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_dev_kube_host"></a> [dev\_kube\_host](#input\_dev\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

### <a name="input_mgmt_cluster_ca_certificate"></a> [mgmt\_cluster\_ca\_certificate](#input\_mgmt\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_mgmt_kube_host"></a> [mgmt\_kube\_host](#input\_mgmt\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

### <a name="input_spn_client_id"></a> [spn\_client\_id](#input\_spn\_client\_id)

Description: Service Principal Client ID

Type: `string`

### <a name="input_stg_cluster_ca_certificate"></a> [stg\_cluster\_ca\_certificate](#input\_stg\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_stg_kube_host"></a> [stg\_kube\_host](#input\_stg\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

No modules.

<!-- END_TF_DOCS -->