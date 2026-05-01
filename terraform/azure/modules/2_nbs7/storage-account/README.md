<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. | `string` | `"GRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. | `string` | `"Standard"` | no |
| <a name="input_blob_container_delete_retention_days"></a> [blob\_container\_delete\_retention\_days](#input\_blob\_container\_delete\_retention\_days) | Number of days to retain soft delete containers. Default 7 days. | `number` | `7` | no |
| <a name="input_blob_delete_retention_days"></a> [blob\_delete\_retention\_days](#input\_blob\_delete\_retention\_days) | Number of days to retain soft deleted blobs. Default 7 days. | `number` | `7` | no |
| <a name="input_blob_private_ip_address"></a> [blob\_private\_ip\_address](#input\_blob\_private\_ip\_address) | Private IP address to set for storage account file endpoint. (leave null to auto assign) | `string` | `null` | no |
| <a name="input_create_dns_record"></a> [create\_dns\_record](#input\_create\_dns\_record) | Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint. | `bool` | `false` | no |
| <a name="input_dns_zone_id_blob"></a> [dns\_zone\_id\_blob](#input\_dns\_zone\_id\_blob) | Zone id of DNS to which record will be added for blob storage.(create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_dns_zone_id_file"></a> [dns\_zone\_id\_file](#input\_dns\_zone\_id\_file) | Zone id of DNS to which record will be added for file storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_dns_zone_name_blob"></a> [dns\_zone\_name\_blob](#input\_dns\_zone\_name\_blob) | Name of DNS zone to which record will be added for blob storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_dns_zone_name_file"></a> [dns\_zone\_name\_file](#input\_dns\_zone\_name\_file) | Name of DNS zone to which record will be added for file storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_file_private_ip_address"></a> [file\_private\_ip\_address](#input\_file\_private\_ip\_address) | Private IP address to set for storage account file endpoint. (leave null to auto assign) | `string` | `null` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Is infrastructure encryption enabled? | `bool` | `true` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the public network access is enabled? | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for existing and to be deployed azure resources | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only) | `string` | `"nbsstorageaccount"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of subnet within virtual\_network\_name to be associated with storage account private endpoints. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of virtual network to be associated with storage account private endpoints. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->