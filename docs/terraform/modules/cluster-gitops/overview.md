<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~> 2.47.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (~> 2.13)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (~> 2.23)

## Resources

The following resources are used by this module:

- [azuread_application.argocd](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) (resource)
- [azuread_application_federated_identity_credential.argocd_federation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) (resource)
- [azuread_service_principal.argocd](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) (resource)
- [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
- [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) (resource)
- [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) (data source)
- [azuread_service_principal.ms_graph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_SPN_CLIENT_SECRET"></a> [SPN\_CLIENT\_SECRET](#input\_SPN\_CLIENT\_SECRET)

Description: SPN account secret

Type: `string`

### <a name="input_argocd_admin_password"></a> [argocd\_admin\_password](#input\_argocd\_admin\_password)

Description: The name of the AKS cluster

Type: `string`

### <a name="input_client_certificate"></a> [client\_certificate](#input\_client\_certificate)

Description: The resource group name of the AKS cluster

Type: `string`

### <a name="input_client_key"></a> [client\_key](#input\_client\_key)

Description: The name of the AKS cluster

Type: `string`

### <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_cluster_tenant_id"></a> [cluster\_tenant\_id](#input\_cluster\_tenant\_id)

Description: Identifier of the Entra tenant where the cluster is deployed

Type: `string`

### <a name="input_entra_admin_group_id"></a> [entra\_admin\_group\_id](#input\_entra\_admin\_group\_id)

Description: Identifier of the Entra admin group that will be granted admin access to ArgoCD

Type: `string`

### <a name="input_fq_cluster_name"></a> [fq\_cluster\_name](#input\_fq\_cluster\_name)

Description: The name of the AKS cluster

Type: `string`

### <a name="input_k8tre_cluster_subscription_id"></a> [k8tre\_cluster\_subscription\_id](#input\_k8tre\_cluster\_subscription\_id)

Description: sub id

Type: `string`

### <a name="input_kube_host"></a> [kube\_host](#input\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group name of the AKS cluster

Type: `string`

### <a name="input_spn_client_id"></a> [spn\_client\_id](#input\_spn\_client\_id)

Description: Identifier of the Service Principal that will be used to authenticate to the cluster

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

No modules.

<!-- END_TF_DOCS -->