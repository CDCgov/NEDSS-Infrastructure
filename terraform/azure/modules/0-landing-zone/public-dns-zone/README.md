# Terraform Azure Module: 0-landing-zone/public-dns-zone

## Description

This module deploys and configures Azure Public DNS Zones and related resources for NBS7.

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

### Modules

| Name                                                                 | Source               | Version |
| -------------------------------------------------------------------- | -------------------- | ------- |
| <a name="module_dns_records"></a> [dns_records](#module_dns_records) | ./modules/dns-record | n/a     |

### Resources

| Name                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

### Inputs

| Name                                                                                       | Description                                                                                   | Type                                                                                                                                                                                             | Default | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | :------: |
| <a name="input_dns_records"></a> [dns_records](#input_dns_records)                         | A map of DNS records to create                                                                | <pre>map(object({<br/> record_name = string<br/> record_type = string<br/> ttl = optional(number, 300)<br/> records = optional(list(string))<br/> cname_record = optional(string)<br/> }))</pre> | `{}`    |    no    |
| <a name="input_enabled"></a> [enabled](#input_enabled)                                     | Whether to have Terraform provision the resources from this module in your Azure subscription | `bool`                                                                                                                                                                                           | `true`  |    no    |
| <a name="input_public_domain_name"></a> [public_domain_name](#input_public_domain_name)    | The root domain (e.g., example.com)                                                           | `string`                                                                                                                                                                                         | `""`    |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name                                                                           | `string`                                                                                                                                                                                         | `""`    |    no    |

### Outputs

| Name                                                                 | Description |
| -------------------------------------------------------------------- | ----------- |
| <a name="output_dns_zone_id"></a> [dns_zone_id](#output_dns_zone_id) | n/a         |

<!-- END_TF_DOCS -->
