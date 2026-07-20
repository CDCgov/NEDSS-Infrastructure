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

| Name                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name                                                                                       | Description                                                                                   | Type     | Default | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input_enabled)                                     | Whether to have Terraform provision the resources from this module in your Azure subscription | `bool`   | `true`  |    no    |
| <a name="input_public_domain_name"></a> [public_domain_name](#input_public_domain_name)    | The root domain (e.g., example.com)                                                           | `string` | `""`    |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name                                                                           | `string` | `""`    |    no    |

## Outputs

| Name                                                                 | Description |
| -------------------------------------------------------------------- | ----------- |
| <a name="output_dns_zone_id"></a> [dns_zone_id](#output_dns_zone_id) | n/a         |

<!-- END_TF_DOCS -->
