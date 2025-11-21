<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.11.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.26.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (~> 2.13)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (~> 2.23)

## Resources

The following resources are used by this module:

- [azurerm_federated_identity_credential.externaldns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) (resource)
- [azurerm_private_dns_zone.dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.externaldns_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_role_assignment.externaldns_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_user_assigned_identity.externaldns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_virtual_network.hub_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_SPN_CLIENT_SECRET"></a> [SPN\_CLIENT\_SECRET](#input\_SPN\_CLIENT\_SECRET)

Description: SPN account secret

Type: `string`

### <a name="input_azure_k8tre_connectivity_subscription_id"></a> [azure\_k8tre\_connectivity\_subscription\_id](#input\_azure\_k8tre\_connectivity\_subscription\_id)

Description: target cluster subscription id

Type: `string`

### <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id)

Description: Azure tenant ID

Type: `string`

### <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate)

Description: The base64-encoded cluster CA certificate

Type: `string`

### <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name)

Description: The domain name for the cluster DNS

Type: `string`

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: The name of the AKS cluster

Type: `string`

### <a name="input_cluster_resource_group_name"></a> [cluster\_resource\_group\_name](#input\_cluster\_resource\_group\_name)

Description: The resource group name of the AKS cluster

Type: `string`

### <a name="input_cluster_subscription_id"></a> [cluster\_subscription\_id](#input\_cluster\_subscription\_id)

Description: target cluster subscription id

Type: `string`

### <a name="input_fq_cluster_name"></a> [fq\_cluster\_name](#input\_fq\_cluster\_name)

Description: The fully qualified cluster name (FQDN) of the AKS cluster

Type: `string`

### <a name="input_kube_host"></a> [kube\_host](#input\_kube\_host)

Description: The AKS API server host (FQDN)

Type: `string`

### <a name="input_lz_hub_vnet_name"></a> [lz\_hub\_vnet\_name](#input\_lz\_hub\_vnet\_name)

Description: Name of the landing zone hub VNet

Type: `string`

### <a name="input_lz_network_dns_resource_group_name"></a> [lz\_network\_dns\_resource\_group\_name](#input\_lz\_network\_dns\_resource\_group\_name)

Description: Name of the resource group for the landing zone hub DNS resources

Type: `string`

### <a name="input_lz_network_resource_group_name"></a> [lz\_network\_resource\_group\_name](#input\_lz\_network\_resource\_group\_name)

Description: Name of the resource group for the landing zone hub networking resources

Type: `string`

### <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url)

Description: oidc\_issuer\_url of k8s cluster

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