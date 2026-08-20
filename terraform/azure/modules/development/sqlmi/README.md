# Terraform Azure Module: development/sqlmi

## Description

This module is used to deploy and configure NBS7 development resources for Azure SQL Managed Instances.

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault_secret.sqlmi_password_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.sqlmi_username_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_mssql_managed_instance.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) | resource |
| [random_password.sqlmi_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.sqlmi_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.sqlmi_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix used for naming all resources | `string` | n/a | yes |
| <a name="input_sqlmi_key_vault"></a> [sqlmi\_key\_vault](#input\_sqlmi\_key\_vault) | KeyVault Name to Store SQLMI Credentials. KeyVault Should be Manually Created | `string` | n/a | yes |
| <a name="input_sqlmi_resource_group_name"></a> [sqlmi\_resource\_group\_name](#input\_sqlmi\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_sqlmi_sku_name"></a> [sqlmi\_sku\_name](#input\_sqlmi\_sku\_name) | SKU Name | `string` | n/a | yes |
| <a name="input_sqlmi_storage"></a> [sqlmi\_storage](#input\_sqlmi\_storage) | SQL Storage | `string` | n/a | yes |
| <a name="input_sqlmi_subnet_name"></a> [sqlmi\_subnet\_name](#input\_sqlmi\_subnet\_name) | Subnet to deploy Azure SQl Managed Instance in | `string` | n/a | yes |
| <a name="input_sqlmi_timezone_id"></a> [sqlmi\_timezone\_id](#input\_sqlmi\_timezone\_id) | The TimeZone ID that the SQL Managed Instance will be operating in | `string` | n/a | yes |
| <a name="input_sqlmi_vcore"></a> [sqlmi\_vcore](#input\_sqlmi\_vcore) | SQL Virtual Cores | `string` | n/a | yes |
| <a name="input_sqlmi_vnet_name"></a> [sqlmi\_vnet\_name](#input\_sqlmi\_vnet\_name) | Name of vNet | `string` | n/a | yes |
| <a name="input_sqlmi_restore_point_in_time"></a> [sqlmi\_restore\_point\_in\_time](#input\_sqlmi\_restore\_point\_in\_time) | Restore Point in Time | `string` | `"N/A"` | no |
| <a name="input_sqlmi_restoring_from_database_name"></a> [sqlmi\_restoring\_from\_database\_name](#input\_sqlmi\_restoring\_from\_database\_name) | SQL Managed Database Name to Restore From | `string` | `"N/A"` | no |
| <a name="input_sqlmi_restoring_from_database_rg"></a> [sqlmi\_restoring\_from\_database\_rg](#input\_sqlmi\_restoring\_from\_database\_rg) | SQL Managed Database to Restore From Resource Group | `string` | `"N/A"` | no |
| <a name="input_sqlmi_storage_account_type"></a> [sqlmi\_storage\_account\_type](#input\_sqlmi\_storage\_account\_type) | Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created. Possible values are GRS, GZRS, LRS, and ZRS. Defaults to GRS | `string` | `"ZRS"` | no |
| <a name="input_sqlmi_zone_redundant_enabled"></a> [sqlmi\_zone\_redundant\_enabled](#input\_sqlmi\_zone\_redundant\_enabled) | Specifies whether or not the SQL Managed Instance is zone redundant. Defaults to false. | `string` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_managed_instance_fqdn"></a> [managed\_instance\_fqdn](#output\_managed\_instance\_fqdn) | n/a |
| <a name="output_managed_instance_id"></a> [managed\_instance\_id](#output\_managed\_instance\_id) | n/a |
<!-- END_TF_DOCS -->
