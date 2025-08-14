<!-- BEGIN_TF_DOCS -->


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.7.0, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.26.0)

## Resources

The following resources are used by this module:

- [azurerm_application_gateway.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) (resource)
- [azurerm_private_dns_zone.pe_private_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.hub_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_private_dns_zone_virtual_network_link.iac_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_public_ip.appgw_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_virtual_network.hub_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)
- [azurerm_virtual_network.iac_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_app_gateway_ssl_certificate_filename"></a> [app\_gateway\_ssl\_certificate\_filename](#input\_app\_gateway\_ssl\_certificate\_filename)

Description: App gateway SSL PFX certificate filename in certs directory

Type: `string`

### <a name="input_app_gateway_ssl_certificate_passphrase"></a> [app\_gateway\_ssl\_certificate\_passphrase](#input\_app\_gateway\_ssl\_certificate\_passphrase)

Description: Passphrase for the app gateway SSL PFX certificate

Type: `string`

### <a name="input_azure_k8tre_connectivity_subscription_id"></a> [azure\_k8tre\_connectivity\_subscription\_id](#input\_azure\_k8tre\_connectivity\_subscription\_id)

Description: Subscription ID for Azure landing zone hub networking resources

Type: `string`

### <a name="input_azure_k8tre_iac_subscription_id"></a> [azure\_k8tre\_iac\_subscription\_id](#input\_azure\_k8tre\_iac\_subscription\_id)

Description: Subscription ID for Landing Zone IaC resources

Type: `string`

### <a name="input_internal_dns_zone_name"></a> [internal\_dns\_zone\_name](#input\_internal\_dns\_zone\_name)

Description: The internal DNS zone for K8TRE e.g. k8tre.internal

Type: `string`

### <a name="input_lz_hub_vnet_name"></a> [lz\_hub\_vnet\_name](#input\_lz\_hub\_vnet\_name)

Description: Name of the landing zone hub VNet

Type: `string`

### <a name="input_lz_iac_core_resource_group_name"></a> [lz\_iac\_core\_resource\_group\_name](#input\_lz\_iac\_core\_resource\_group\_name)

Description: Name of the resource group for IaC core resources

Type: `string`

### <a name="input_lz_iac_spoke_vnet_name"></a> [lz\_iac\_spoke\_vnet\_name](#input\_lz\_iac\_spoke\_vnet\_name)

Description: Name of the landing zone spoke VNet for IaC resources

Type: `string`

### <a name="input_lz_network_dns_resource_group_name"></a> [lz\_network\_dns\_resource\_group\_name](#input\_lz\_network\_dns\_resource\_group\_name)

Description: Name of the resource group for the landing zone hub DNS resources

Type: `string`

### <a name="input_lz_network_resource_group_name"></a> [lz\_network\_resource\_group\_name](#input\_lz\_network\_resource\_group\_name)

Description: Name of the resource group for the landing zone hub networking resources

Type: `string`

### <a name="input_public_dns_zone_name"></a> [public\_dns\_zone\_name](#input\_public\_dns\_zone\_name)

Description: The public DNS zone name for an organisations version of K8TRE, e.g. karectl.org

Type: `string`

### <a name="input_region"></a> [region](#input\_region)

Description: infrastructure region

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: Name of the cluster

Type: `string`

Default: `"k8tre"`

### <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags)

Description: Resource tags for Azure policy rules

Type: `map(string)`

Default: `{}`

### <a name="input_environments"></a> [environments](#input\_environments)

Description: names for the environments to be created, e.g. dev, stg, prd

Type: `list(string)`

Default: `[]`

### <a name="input_k8tre_service_domains"></a> [k8tre\_service\_domains](#input\_k8tre\_service\_domains)

Description: service domains for k8tre services that require public ingress, e.g. jupyter, opal, keycloak

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id)

Description: n/a

### <a name="output_private_dns_zone_name"></a> [private\_dns\_zone\_name](#output\_private\_dns\_zone\_name)

Description: n/a

## Modules

No modules.

<!-- END_TF_DOCS -->