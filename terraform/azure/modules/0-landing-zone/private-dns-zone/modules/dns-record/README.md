# Terraform Azure Module: modules/dns-record

## Description

This module deploys and configures DNS records in Azure Private DNS Zones for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |

### Providers

| Name                                                         | Version      |
| ------------------------------------------------------------ | ------------ |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=4.68, <5.0 |

### Resources

| Name                                                                                                                                               | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_private_dns_a_record.a](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record)             | resource |
| [azurerm_private_dns_cname_record.cname](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_cname_record) | resource |

### Inputs

| Name                                                                                       | Description                                                                  | Type           | Default | Required |
| ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_record_name"></a> [record_name](#input_record_name)                         | The name of the private DNS record.                                          | `string`       | n/a     |   yes    |
| <a name="input_record_type"></a> [record_type](#input_record_type)                         | The type of record to create. Must be either 'A' or 'CNAME'.                 | `string`       | n/a     |   yes    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the resource group where the Private DNS zone exists.            | `string`       | n/a     |   yes    |
| <a name="input_zone_name"></a> [zone_name](#input_zone_name)                               | The name of the private DNS zone (e.g., 'privatelink.database.windows.net'). | `string`       | n/a     |   yes    |
| <a name="input_cname_record"></a> [cname_record](#input_cname_record)                      | The target domain name. Required if record_type is 'CNAME'.                  | `string`       | `null`  |    no    |
| <a name="input_records"></a> [records](#input_records)                                     | A list of IPv4 addresses. Required if record_type is 'A'.                    | `list(string)` | `null`  |    no    |
| <a name="input_ttl"></a> [ttl](#input_ttl)                                                 | The Time To Live (TTL) of the DNS record in seconds.                         | `number`       | `3600`  |    no    |

<!-- END_TF_DOCS -->
