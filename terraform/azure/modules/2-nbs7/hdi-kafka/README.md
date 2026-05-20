<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_hdinsight_kafka_cluster.kafka-cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/hdinsight_kafka_cluster) | resource |
| [azurerm_network_security_group.hdi-kafka-sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.allow_tag_custom_any_inbound_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_storage_account.kafka-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.hdi-kafka-storage-container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet_network_security_group_association.kafka-subnet-sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.kafka_subnet_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | n/a | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | n/a | `string` | `"Standard"` | no |
| <a name="input_cluster_tier"></a> [cluster\_tier](#input\_cluster\_tier) | n/a | `string` | `"Standard"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | `"4.0"` | no |
| <a name="input_component_version"></a> [component\_version](#input\_component\_version) | n/a | `string` | `"2.1"` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | n/a | `string` | `"private"` | no |
| <a name="input_destination_address_prefix"></a> [destination\_address\_prefix](#input\_destination\_address\_prefix) | n/a | `string` | `"VirtualNetwork"` | no |
| <a name="input_encryption_in_transit_enabled"></a> [encryption\_in\_transit\_enabled](#input\_encryption\_in\_transit\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_gtwy_password"></a> [gtwy\_password](#input\_gtwy\_password) | n/a | `string` | n/a | yes |
| <a name="input_gtwy_username"></a> [gtwy\_username](#input\_gtwy\_username) | n/a | `string` | n/a | yes |
| <a name="input_head_vm_size"></a> [head\_vm\_size](#input\_head\_vm\_size) | n/a | `string` | `"Standard_D3_V2"` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_kafka_cluster_name"></a> [kafka\_cluster\_name](#input\_kafka\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_kafka_subnet_name"></a> [kafka\_subnet\_name](#input\_kafka\_subnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location for Azure resources | `string` | n/a | yes |
| <a name="input_number_of_disks_per_node"></a> [number\_of\_disks\_per\_node](#input\_number\_of\_disks\_per\_node) | n/a | `number` | `1` | no |
| <a name="input_password"></a> [password](#input\_password) | n/a | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | n/a | `string` | `"dev"` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | n/a | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br/>  "createdby": "Terraform"<br/>}</pre> | no |
| <a name="input_target_instance_count"></a> [target\_instance\_count](#input\_target\_instance\_count) | n/a | `number` | `3` | no |
| <a name="input_tls_min_version"></a> [tls\_min\_version](#input\_tls\_min\_version) | n/a | `string` | `"1.2"` | no |
| <a name="input_username"></a> [username](#input\_username) | n/a | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_vnet_rg"></a> [vnet\_rg](#input\_vnet\_rg) | n/a | `string` | n/a | yes |
| <a name="input_worker_vm_size"></a> [worker\_vm\_size](#input\_worker\_vm\_size) | n/a | `string` | `"Standard_D3_V2"` | no |
| <a name="input_zookeeper_vm_size"></a> [zookeeper\_vm\_size](#input\_zookeeper\_vm\_size) | n/a | `string` | `"Standard_D3_V2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->