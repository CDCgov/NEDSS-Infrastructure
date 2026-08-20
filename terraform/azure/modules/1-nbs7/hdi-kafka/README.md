# Terraform Azure Module: 1-nbs7/hdi-kafka

## Description

This module is used to deploy and configure Azure HDInsights Kafka clusters and related resources for NBS7.

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
| [azurerm_hdinsight_kafka_cluster.kafka_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/hdinsight_kafka_cluster) | resource |
| [azurerm_nat_gateway.kafka_nat_gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.hdi_kafka_sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.allow_hdinsight_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.allow_hdinsight_outbound_80](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.allow_tag_custom_any_inbound_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_private_endpoint.kafka_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_storage_account.kafka_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.hdi_kafka_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet_nat_gateway_association.kafka_subnet_nat_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.kafka_subnet_sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.kafka_subnet_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_gtwy_password"></a> [gtwy\_password](#input\_gtwy\_password) | The password for the Ambari gateway | `string` | n/a | yes |
| <a name="input_gtwy_username"></a> [gtwy\_username](#input\_gtwy\_username) | The username for the Ambari gateway | `string` | n/a | yes |
| <a name="input_kafka_cluster_name"></a> [kafka\_cluster\_name](#input\_kafka\_cluster\_name) | The name of the Kafka cluster | `string` | n/a | yes |
| <a name="input_kafka_subnet_name"></a> [kafka\_subnet\_name](#input\_kafka\_subnet\_name) | The name of the Kafka subnet | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use for the resources | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | The password for the Kafka cluster login | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | The name of the security group | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to use with Kafka | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | The username for the Kafka cluster login | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network | `string` | n/a | yes |
| <a name="input_vnet_rg"></a> [vnet\_rg](#input\_vnet\_rg) | The name of the resource group that holds the virtual network | `string` | n/a | yes |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | The replication type of the storage account | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The performance tier of the storage account | `string` | `"Standard"` | no |
| <a name="input_cluster_tier"></a> [cluster\_tier](#input\_cluster\_tier) | The tier of the HDInsight cluster | `string` | `"Standard"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The version of the HDInsight cluster | `string` | `"5.1"` | no |
| <a name="input_component_version"></a> [component\_version](#input\_component\_version) | The version of the Kafka component | `string` | `"3.2"` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | The access type of the storage container | `string` | `"private"` | no |
| <a name="input_destination_address_prefix"></a> [destination\_address\_prefix](#input\_destination\_address\_prefix) | The destination address prefix for the network security rule | `string` | `"VirtualNetwork"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable the module | `bool` | `true` | no |
| <a name="input_encryption_in_transit_enabled"></a> [encryption\_in\_transit\_enabled](#input\_encryption\_in\_transit\_enabled) | Set to true to enable encryption in transit | `bool` | `true` | no |
| <a name="input_head_vm_size"></a> [head\_vm\_size](#input\_head\_vm\_size) | The VM size of the head node | `string` | `"Standard_D3_V2"` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Set to true to enable infrastructure encryption | `bool` | `true` | no |
| <a name="input_nat_gateway_enabled"></a> [nat\_gateway\_enabled](#input\_nat\_gateway\_enabled) | Enable NAT gateway to allow VM helath checks to reach the management api | `bool` | `true` | no |
| <a name="input_number_of_disks_per_node"></a> [number\_of\_disks\_per\_node](#input\_number\_of\_disks\_per\_node) | The number of disks to attach to each worker node | `number` | `1` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for all Kafka resources | `string` | `"dev"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | <pre>{<br/>  "createdby": "Terraform"<br/>}</pre> | no |
| <a name="input_target_instance_count"></a> [target\_instance\_count](#input\_target\_instance\_count) | The target number of worker node instances | `number` | `3` | no |
| <a name="input_tls_min_version"></a> [tls\_min\_version](#input\_tls\_min\_version) | The minimum TLS version to allow | `string` | `"1.2"` | no |
| <a name="input_worker_vm_size"></a> [worker\_vm\_size](#input\_worker\_vm\_size) | The VM size of the worker node | `string` | `"Standard_D3_V2"` | no |
| <a name="input_zookeeper_vm_size"></a> [zookeeper\_vm\_size](#input\_zookeeper\_vm\_size) | The VM size of the zookeeper node | `string` | `"Standard_D3_V2"` | no |
<!-- END_TF_DOCS -->
