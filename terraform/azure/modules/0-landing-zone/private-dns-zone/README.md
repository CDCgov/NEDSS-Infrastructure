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

| Name                                                                 | Source               | Version |
| -------------------------------------------------------------------- | -------------------- | ------- |
| <a name="module_dns_records"></a> [dns_records](#module_dns_records) | ./modules/dns-record | n/a     |

## Resources

| Name                                                                                                                                                                           | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [azurerm_private_dns_zone.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)                                           | resource    |
| [azurerm_private_dns_zone_virtual_network_link.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource    |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                 | data source |

## Inputs

| Name                                                                                             | Description                                                                                   | Type                                                                                                                                                                                             | Default | Required |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | :------: |
| <a name="input_dns_records"></a> [dns_records](#input_dns_records)                               | A map of DNS records to create                                                                | <pre>map(object({<br/> record_name = string<br/> record_type = string<br/> ttl = optional(number, 300)<br/> records = optional(list(string))<br/> cname_record = optional(string)<br/> }))</pre> | `{}`    |    no    |
| <a name="input_enabled"></a> [enabled](#input_enabled)                                           | Whether to have Terraform provision the resources from this module in your Azure subscription | `bool`                                                                                                                                                                                           | `true`  |    no    |
| <a name="input_private_dns_zone_name"></a> [private_dns_zone_name](#input_private_dns_zone_name) | Name for the private dns zone                                                                 | `string`                                                                                                                                                                                         | `""`    |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)       | The name of the resource group                                                                | `string`                                                                                                                                                                                         | `""`    |    no    |
| <a name="input_vnet_id"></a> [vnet_id](#input_vnet_id)                                           | vnet id                                                                                       | `string`                                                                                                                                                                                         | n/a     |   yes    |
| <a name="input_vnet_name"></a> [vnet_name](#input_vnet_name)                                     | vnet name                                                                                     | `string`                                                                                                                                                                                         | n/a     |   yes    |

## Outputs

| Name                                                                                         | Description |
| -------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_private_dns_zone_id"></a> [private_dns_zone_id](#output_private_dns_zone_id) | n/a         |

<!-- END_TF_DOCS -->
