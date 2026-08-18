# Terraform Azure Module: modules/dns-record

## Description

This module is used to deploy and configure DNS records in Azure Public DNS Zones for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_dns_a_record.a](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_cname_record.cname](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_record_name"></a> [record\_name](#input\_record\_name) | The name of the DNS record (e.g., 'www' or '@' for root). | `string` | n/a | yes |
| <a name="input_record_type"></a> [record\_type](#input\_record\_type) | The type of record to create. Must be either 'A' or 'CNAME'. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the DNS zone exists. | `string` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | The name of the public DNS zone. | `string` | n/a | yes |
| <a name="input_cname_record"></a> [cname\_record](#input\_cname\_record) | The target domain name. Required if record\_type is 'CNAME'. | `string` | `null` | no |
| <a name="input_records"></a> [records](#input\_records) | A list of IPv4 addresses. Required if record\_type is 'A'. | `list(string)` | `null` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The Time To Live (TTL) of the DNS record in seconds. | `number` | `3600` | no |
<!-- END_TF_DOCS -->
