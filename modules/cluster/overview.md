<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.7.0, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.26.0)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_private_dns_zone_virtual_network_link.spoke_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_resource_group.cluster_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_assignment.aks_can_write_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.aks_file_share_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.aks_kv_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.aks_storage_account_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_user_assigned_identity.aks_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_private_dns_zone.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_private_dns_zone.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_subnet.cluster_spoke_aks_node_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.cluster_spoke_private_endpoints_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_virtual_network.cluster_spoke_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_entra_admin_group_id"></a> [entra\_admin\_group\_id](#input\_entra\_admin\_group\_id)

Description: Entra k8s admin group id

Type: `string`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: The name of target cluster environment

Type: `string`

### <a name="input_k8tre_cluster_subscription_id"></a> [k8tre\_cluster\_subscription\_id](#input\_k8tre\_cluster\_subscription\_id)

Description: target cluster sub id

Type: `string`

### <a name="input_k8tre_connectivity_subscription_id"></a> [k8tre\_connectivity\_subscription\_id](#input\_k8tre\_connectivity\_subscription\_id)

Description: infra networking sub id

Type: `string`

### <a name="input_lz_network_dns_resource_group_name"></a> [lz\_network\_dns\_resource\_group\_name](#input\_lz\_network\_dns\_resource\_group\_name)

Description: Resource group name for the landing zone network DNS resources

Type: `string`

### <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id)

Description: private dns id

Type: `string`

### <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name)

Description: private dns name

Type: `string`

### <a name="input_region"></a> [region](#input\_region)

Description: infrastructure region

Type: `string`

### <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id)

Description: Azure tenant id

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_service_name"></a> [service\_name](#input\_service\_name)

Description: Name of the service

Type: `string`

Default: `"k8tre"`

## Outputs

The following outputs are exported:

### <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate)

Description: n/a

### <a name="output_client_key"></a> [client\_key](#output\_client\_key)

Description: n/a

### <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate)

Description: n/a

### <a name="output_environment"></a> [environment](#output\_environment)

Description: n/a

### <a name="output_fq_cluster_name"></a> [fq\_cluster\_name](#output\_fq\_cluster\_name)

Description: n/a

### <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config)

Description: n/a

### <a name="output_kube_host"></a> [kube\_host](#output\_kube\_host)

Description: n/a

### <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url)

Description: n/a

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_aks_cluster"></a> [aks\_cluster](#module\_aks\_cluster)

Source: ./avm-patterns/avm-ptn-aks-production

Version:

<!-- END_TF_DOCS -->