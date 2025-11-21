<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.11.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.34.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (~> 2.13)

- <a name="requirement_http"></a> [http](#requirement\_http) (~> 3.0)

- <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) (~> 1.19.0)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (~> 2.37.1)

## Resources

The following resources are used by this module:

- [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
- [kubectl_manifest.gateway__crds](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) (resource)
- [http_http.gateway_crds](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_SPN_CLIENT_SECRET"></a> [SPN\_CLIENT\_SECRET](#input\_SPN\_CLIENT\_SECRET)

Description: SPN account secret

Type: `string`

### <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id)

Description: Azure tenant ID

Type: `string`

### <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: The name of the AKS cluster

Type: `string`

### <a name="input_kube_host"></a> [kube\_host](#input\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

### <a name="input_spn_client_id"></a> [spn\_client\_id](#input\_spn\_client\_id)

Description: Service Principal Client ID

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

No modules.

<!-- END_TF_DOCS -->