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

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name                                                                                       | Description                          | Type     | Default     | Required |
| ------------------------------------------------------------------------------------------ | ------------------------------------ | -------- | ----------- | :------: |
| <a name="input_enabled"></a> [enabled](#input_enabled)                                     | Whether to create the resource group | `bool`   | `true`      |    no    |
| <a name="input_location"></a> [location](#input_location)                                  | The Azure region (e.g., East US)     | `string` | `"East US"` |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the resource group       | `string` | n/a         |   yes    |

## Outputs

| Name                                                        | Description             |
| ----------------------------------------------------------- | ----------------------- |
| <a name="output_id"></a> [id](#output_id)                   | Resource group ID       |
| <a name="output_location"></a> [location](#output_location) | Resource group location |
| <a name="output_name"></a> [name](#output_name)             | Resource group name     |

<!-- END_TF_DOCS -->
