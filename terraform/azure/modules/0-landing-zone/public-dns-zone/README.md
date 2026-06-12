<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable the module | `bool` | `true` | no |
| <a name="input_public_domain_name"></a> [public\_domain\_name](#input\_public\_domain\_name) | The root domain (e.g., example.com) | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | n/a |
<!-- END_TF_DOCS -->