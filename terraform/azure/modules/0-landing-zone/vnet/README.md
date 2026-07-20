<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |

## Providers

| Name                                                         | Version      |
| ------------------------------------------------------------ | ------------ |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=4.68, <5.0 |

## Modules

| Name                                            | Source                                       | Version |
| ----------------------------------------------- | -------------------------------------------- | ------- |
| <a name="module_vnet"></a> [vnet](#module_vnet) | Azure/avm-res-network-virtualnetwork/azurerm | >=0.1.7 |

## Resources

| Name                                                                                                                           | Type        |
| ------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name                                                                                       | Description                                                              | Type           | Default    | Required |
| ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | -------------- | ---------- | :------: |
| <a name="input_parent_id"></a> [parent_id](#input_parent_id)                               | The ID of the existing resource group where the VNet will be provisioned | `string`       | n/a        |   yes    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the existing resource group                                  | `string`       | n/a        |   yes    |
| <a name="input_vnet_location"></a> [vnet_location](#input_vnet_location)                   | The Azure region                                                         | `string`       | `"eastus"` |    no    |
| <a name="input_vnet_name"></a> [vnet_name](#input_vnet_name)                               | Name of the vnet                                                         | `string`       | `"nbs"`    |    no    |
| <a name="input_address_space"></a> [address_space](#input_address_space)                   | Address space for the VNet                                               | `list(string)` | n/a        |   yes    |

## Outputs

| Name                                                                 | Description                         |
| -------------------------------------------------------------------- | ----------------------------------- |
| <a name="output_resource_id"></a> [resource_id](#output_resource_id) | n/a                                 |
| <a name="output_subnets"></a> [subnets](#output_subnets)             | Map of subnet names to resource IDs |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id)             | The ID of the Virtual Network       |
| <a name="output_vnet_name"></a> [vnet_name](#output_vnet_name)       | The name of the Virtual Network     |

<!-- END_TF_DOCS -->
