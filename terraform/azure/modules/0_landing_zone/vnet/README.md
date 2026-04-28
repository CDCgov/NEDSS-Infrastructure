<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vnet"></a> [vnet](#module\_vnet) | Azure/avm-res-network-virtualnetwork/azurerm | >=0.1.7 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | The name of the existing resource group | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_vnet_location"></a> [vnet\_location](#input\_vnet\_location) | The Azure region (e.g., East US) | `string` | `"East US"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vnet | `string` | `"nbs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of subnet names to resource IDs |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the Virtual Network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the Virtual Network |
<!-- END_TF_DOCS -->