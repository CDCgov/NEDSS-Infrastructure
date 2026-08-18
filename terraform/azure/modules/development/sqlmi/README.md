# Terraform Azure Module: development/sqlmi

## Description

This module is used to deploy and configure NBS7 development resources for Azure SQL Managed Instances.

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
| <a name="provider_random"></a> [random](#provider_random)    | n/a          |

## Modules

No modules.

## Resources

| Name                                                                                                                                               | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_key_vault_secret.sqlmi_password_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource    |
| [azurerm_key_vault_secret.sqlmi_username_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource    |
| [azurerm_mssql_managed_instance.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance)     | resource    |
| [random_password.sqlmi_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                          | resource    |
| [random_string.sqlmi_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                              | resource    |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)                        | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                     | data source |
| [azurerm_subnet.sqlmi_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                           | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network)                 | data source |

## Inputs

| Name                                                                                                                                    | Description                                                                                                                                                                                 | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                          | Prefix used for naming all resources                                                                                                                                                        | `string` | n/a     |   yes    |
| <a name="input_sqlmi_key_vault"></a> [sqlmi_key_vault](#input_sqlmi_key_vault)                                                          | KeyVault Name to Store SQLMI Credentials. KeyVault Should be Manually Created                                                                                                               | `string` | n/a     |   yes    |
| <a name="input_sqlmi_resource_group_name"></a> [sqlmi_resource_group_name](#input_sqlmi_resource_group_name)                            | The name of the resource group                                                                                                                                                              | `string` | n/a     |   yes    |
| <a name="input_sqlmi_restore_point_in_time"></a> [sqlmi_restore_point_in_time](#input_sqlmi_restore_point_in_time)                      | Restore Point in Time                                                                                                                                                                       | `string` | `"N/A"` |    no    |
| <a name="input_sqlmi_restoring_from_database_name"></a> [sqlmi_restoring_from_database_name](#input_sqlmi_restoring_from_database_name) | SQL Managed Database Name to Restore From                                                                                                                                                   | `string` | `"N/A"` |    no    |
| <a name="input_sqlmi_restoring_from_database_rg"></a> [sqlmi_restoring_from_database_rg](#input_sqlmi_restoring_from_database_rg)       | SQL Managed Database to Restore From Resource Group                                                                                                                                         | `string` | `"N/A"` |    no    |
| <a name="input_sqlmi_sku_name"></a> [sqlmi_sku_name](#input_sqlmi_sku_name)                                                             | SKU Name                                                                                                                                                                                    | `string` | n/a     |   yes    |
| <a name="input_sqlmi_storage"></a> [sqlmi_storage](#input_sqlmi_storage)                                                                | SQL Storage                                                                                                                                                                                 | `string` | n/a     |   yes    |
| <a name="input_sqlmi_storage_account_type"></a> [sqlmi_storage_account_type](#input_sqlmi_storage_account_type)                         | Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created. Possible values are GRS, GZRS, LRS, and ZRS. Defaults to GRS | `string` | `"ZRS"` |    no    |
| <a name="input_sqlmi_subnet_name"></a> [sqlmi_subnet_name](#input_sqlmi_subnet_name)                                                    | Subnet to deploy Azure SQl Managed Instance in                                                                                                                                              | `string` | n/a     |   yes    |
| <a name="input_sqlmi_timezone_id"></a> [sqlmi_timezone_id](#input_sqlmi_timezone_id)                                                    | The TimeZone ID that the SQL Managed Instance will be operating in                                                                                                                          | `string` | n/a     |   yes    |
| <a name="input_sqlmi_vcore"></a> [sqlmi_vcore](#input_sqlmi_vcore)                                                                      | SQL Virtual Cores                                                                                                                                                                           | `string` | n/a     |   yes    |
| <a name="input_sqlmi_vnet_name"></a> [sqlmi_vnet_name](#input_sqlmi_vnet_name)                                                          | Name of vNet                                                                                                                                                                                | `string` | n/a     |   yes    |
| <a name="input_sqlmi_zone_redundant_enabled"></a> [sqlmi_zone_redundant_enabled](#input_sqlmi_zone_redundant_enabled)                   | Specifies whether or not the SQL Managed Instance is zone redundant. Defaults to false.                                                                                                     | `string` | `true`  |    no    |

## Outputs

| Name                                                                                               | Description |
| -------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_managed_instance_fqdn"></a> [managed_instance_fqdn](#output_managed_instance_fqdn) | n/a         |
| <a name="output_managed_instance_id"></a> [managed_instance_id](#output_managed_instance_id)       | n/a         |

<!-- END_TF_DOCS -->
