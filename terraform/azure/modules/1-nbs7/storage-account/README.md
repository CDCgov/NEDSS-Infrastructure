# Terraform Azure Module: 1-nbs7/storage-account

## Description

This module is used to deploy and configure Azure Storage Accounts and related resources for NBS7.

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

| Name                                                                                                                                       | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)          | resource    |
| [azurerm_private_endpoint.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)          | resource    |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource    |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)           | data source |
| [azurerm_subnet.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                       | data source |

## Inputs

| Name                                                                                                                                          | Description                                                                                                                                                                                                                                                  | Type     | Default               | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | --------------------- | :------: |
| <a name="input_account_kind"></a> [account_kind](#input_account_kind)                                                                         | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.                                                                                                                                            | `string` | `"StorageV2"`         |    no    |
| <a name="input_account_replication_type"></a> [account_replication_type](#input_account_replication_type)                                     | Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. | `string` | `"GRS"`               |    no    |
| <a name="input_account_tier"></a> [account_tier](#input_account_tier)                                                                         | Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created.                                            | `string` | `"Standard"`          |    no    |
| <a name="input_blob_container_delete_retention_days"></a> [blob_container_delete_retention_days](#input_blob_container_delete_retention_days) | Number of days to retain soft delete containers. Default 7 days.                                                                                                                                                                                             | `number` | `7`                   |    no    |
| <a name="input_blob_delete_retention_days"></a> [blob_delete_retention_days](#input_blob_delete_retention_days)                               | Number of days to retain soft deleted blobs. Default 7 days.                                                                                                                                                                                                 | `number` | `7`                   |    no    |
| <a name="input_blob_private_ip_address"></a> [blob_private_ip_address](#input_blob_private_ip_address)                                        | Private IP address to set for storage account file endpoint. (leave null to auto assign)                                                                                                                                                                     | `string` | `null`                |    no    |
| <a name="input_create_dns_record"></a> [create_dns_record](#input_create_dns_record)                                                          | Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint.                                                                                                                                        | `bool`   | `false`               |    no    |
| <a name="input_dns_zone_id_blob"></a> [dns_zone_id_blob](#input_dns_zone_id_blob)                                                             | Zone id of DNS to which record will be added for blob storage.(create_dns_record must be true)                                                                                                                                                               | `string` | `""`                  |    no    |
| <a name="input_dns_zone_id_file"></a> [dns_zone_id_file](#input_dns_zone_id_file)                                                             | Zone id of DNS to which record will be added for file storage. (create_dns_record must be true)                                                                                                                                                              | `string` | `""`                  |    no    |
| <a name="input_dns_zone_name_blob"></a> [dns_zone_name_blob](#input_dns_zone_name_blob)                                                       | Name of DNS zone to which record will be added for blob storage. (create_dns_record must be true)                                                                                                                                                            | `string` | `""`                  |    no    |
| <a name="input_dns_zone_name_file"></a> [dns_zone_name_file](#input_dns_zone_name_file)                                                       | Name of DNS zone to which record will be added for file storage. (create_dns_record must be true)                                                                                                                                                            | `string` | `""`                  |    no    |
| <a name="input_file_private_ip_address"></a> [file_private_ip_address](#input_file_private_ip_address)                                        | Private IP address to set for storage account file endpoint. (leave null to auto assign)                                                                                                                                                                     | `string` | `null`                |    no    |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure_encryption_enabled](#input_infrastructure_encryption_enabled)          | Is infrastructure encryption enabled?                                                                                                                                                                                                                        | `bool`   | `true`                |    no    |
| <a name="input_public_network_access_enabled"></a> [public_network_access_enabled](#input_public_network_access_enabled)                      | Whether the public network access is enabled?                                                                                                                                                                                                                | `bool`   | `false`               |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                                                    | Resource group name for existing and to be deployed azure resources                                                                                                                                                                                          | `string` | n/a                   |   yes    |
| <a name="input_storage_account_name"></a> [storage_account_name](#input_storage_account_name)                                                 | Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)                                                                                                                           | `string` | `"nbsstorageaccount"` |    no    |
| <a name="input_subnet_name"></a> [subnet_name](#input_subnet_name)                                                                            | Name of subnet within virtual_network_name to be associated with storage account private endpoints.                                                                                                                                                          | `string` | n/a                   |   yes    |
| <a name="input_virtual_network_name"></a> [virtual_network_name](#input_virtual_network_name)                                                 | Name of virtual network to be associated with storage account private endpoints.                                                                                                                                                                             | `string` | n/a                   |   yes    |

## Outputs

| Name                                                                                            | Description |
| ----------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_storage_account_id"></a> [storage_account_id](#output_storage_account_id)       | n/a         |
| <a name="output_storage_account_name"></a> [storage_account_name](#output_storage_account_name) | n/a         |

<!-- END_TF_DOCS -->
