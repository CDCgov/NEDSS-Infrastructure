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

| Name                                                                                                                                                                                           | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_hdinsight_kafka_cluster.kafka-cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/hdinsight_kafka_cluster)                                       | resource    |
| [azurerm_network_security_group.hdi-kafka-sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                          | resource    |
| [azurerm_network_security_rule.allow_tag_custom_any_inbound_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                       | resource    |
| [azurerm_storage_account.kafka-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)                                               | resource    |
| [azurerm_storage_container.hdi-kafka-storage-container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)                                     | resource    |
| [azurerm_subnet_network_security_group_association.kafka-subnet-sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource    |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                                 | data source |
| [azurerm_subnet.kafka_subnet_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                                                                  | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network)                                                             | data source |

## Inputs

| Name                                                                                                                                 | Description                  | Type          | Default                                          | Required |
| ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------- | ------------- | ------------------------------------------------ | :------: |
| <a name="input_account_replication_type"></a> [account_replication_type](#input_account_replication_type)                            | n/a                          | `string`      | `"LRS"`                                          |    no    |
| <a name="input_account_tier"></a> [account_tier](#input_account_tier)                                                                | n/a                          | `string`      | `"Standard"`                                     |    no    |
| <a name="input_cluster_tier"></a> [cluster_tier](#input_cluster_tier)                                                                | n/a                          | `string`      | `"Standard"`                                     |    no    |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version)                                                       | n/a                          | `string`      | `"4.0"`                                          |    no    |
| <a name="input_component_version"></a> [component_version](#input_component_version)                                                 | n/a                          | `string`      | `"2.1"`                                          |    no    |
| <a name="input_container_access_type"></a> [container_access_type](#input_container_access_type)                                     | n/a                          | `string`      | `"private"`                                      |    no    |
| <a name="input_destination_address_prefix"></a> [destination_address_prefix](#input_destination_address_prefix)                      | n/a                          | `string`      | `"VirtualNetwork"`                               |    no    |
| <a name="input_encryption_in_transit_enabled"></a> [encryption_in_transit_enabled](#input_encryption_in_transit_enabled)             | n/a                          | `bool`        | `true`                                           |    no    |
| <a name="input_gtwy_password"></a> [gtwy_password](#input_gtwy_password)                                                             | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_gtwy_username"></a> [gtwy_username](#input_gtwy_username)                                                             | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_head_vm_size"></a> [head_vm_size](#input_head_vm_size)                                                                | n/a                          | `string`      | `"Standard_D3_V2"`                               |    no    |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure_encryption_enabled](#input_infrastructure_encryption_enabled) | n/a                          | `bool`        | `true`                                           |    no    |
| <a name="input_kafka_cluster_name"></a> [kafka_cluster_name](#input_kafka_cluster_name)                                              | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_kafka_subnet_name"></a> [kafka_subnet_name](#input_kafka_subnet_name)                                                 | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_location"></a> [location](#input_location)                                                                            | Location for Azure resources | `string`      | n/a                                              |   yes    |
| <a name="input_number_of_disks_per_node"></a> [number_of_disks_per_node](#input_number_of_disks_per_node)                            | n/a                          | `number`      | `1`                                              |    no    |
| <a name="input_password"></a> [password](#input_password)                                                                            | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                       | n/a                          | `string`      | `"dev"`                                          |    no    |
| <a name="input_sg_name"></a> [sg_name](#input_sg_name)                                                                               | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_storage_account_name"></a> [storage_account_name](#input_storage_account_name)                                        | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                        | n/a                          | `map(string)` | <pre>{<br/> "createdby": "Terraform"<br/>}</pre> |    no    |
| <a name="input_target_instance_count"></a> [target_instance_count](#input_target_instance_count)                                     | n/a                          | `number`      | `3`                                              |    no    |
| <a name="input_tls_min_version"></a> [tls_min_version](#input_tls_min_version)                                                       | n/a                          | `string`      | `"1.2"`                                          |    no    |
| <a name="input_username"></a> [username](#input_username)                                                                            | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_vnet_name"></a> [vnet_name](#input_vnet_name)                                                                         | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_vnet_rg"></a> [vnet_rg](#input_vnet_rg)                                                                               | n/a                          | `string`      | n/a                                              |   yes    |
| <a name="input_worker_vm_size"></a> [worker_vm_size](#input_worker_vm_size)                                                          | n/a                          | `string`      | `"Standard_D3_V2"`                               |    no    |
| <a name="input_zookeeper_vm_size"></a> [zookeeper_vm_size](#input_zookeeper_vm_size)                                                 | n/a                          | `string`      | `"Standard_D3_V2"`                               |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
