# CDCgov GitHub Organization Open Source Project Template

**Template for clearance: This project serves as a template to aid projects in starting up and moving through clearance procedures. To start, create a new repository and implement the required [open practices](open_practices.md), train on and agree to adhere to the organization's [rules of behavior](rules_of_behavior.md), and [send a request through the create repo form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) using language from this template as a Guide.**

**General disclaimer** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/organization/mission.htm).  GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise. 

## Access Request, Repo Creation Request

* [CDC GitHub Open Project Request Form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) _[Requires a CDC Office365 login, if you do not have a CDC Office365 please ask a friend who does to submit the request on your behalf. If you're looking for access to the CDCEnt private organization, please use the [GitHub Enterprise Cloud Access Request form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUQjVJVDlKS1c0SlhQSUxLNVBaOEZCNUczVS4u).]_

## Related documents

* [Open Practices](open_practices.md)
* [Rules of Behavior](rules_of_behavior.md)
* [Thanks and Acknowledgements](thanks.md)
* [Disclaimer](DISCLAIMER.md)
* [Contribution Notice](CONTRIBUTING.md)
* [Code of Conduct](code-of-conduct.md)

## Overview

Infrastructure required by the NEDSS application is contained within. Currently, the main method of deployment is Terraform which have been split out into modules.
  
## Public Domain Standard Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice
The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices
Please refer to [CDC's Template Repository](https://github.com/CDCgov/template)
for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md),
[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md),
and [code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_agw_public"></a> [agw\_public](#module\_agw\_public) | ../../modules/1-nbs7/agw-public | n/a |
| <a name="module_aks_nbs7"></a> [aks\_nbs7](#module\_aks\_nbs7) | ../../modules/1-nbs7/aks | n/a |
| <a name="module_kafka"></a> [kafka](#module\_kafka) | ../../modules/1-nbs7/hdi-kafka | n/a |
| <a name="module_observability"></a> [observability](#module\_observability) | ../../modules/1-nbs7/observability | n/a |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../../modules/1-nbs7/storage-account | n/a |
| <a name="module_storage_dns_zone"></a> [storage\_dns\_zone](#module\_storage\_dns\_zone) | ../../modules/1-nbs7/storage-dns-zone | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_agw_aks_ip"></a> [agw\_aks\_ip](#input\_agw\_aks\_ip) | The private IP address of the Azure Kubernetes Service (AKS) internal <br/>load balancer backend. | `string` | n/a | yes |
| <a name="input_agw_app_backend_host"></a> [agw\_app\_backend\_host](#input\_agw\_app\_backend\_host) | The target host header or FQDN expected by the Traefik ingress <br/>controller for routing. | `string` | n/a | yes |
| <a name="input_agw_app_public_hostname"></a> [agw\_app\_public\_hostname](#input\_agw\_app\_public\_hostname) | The public FQDN mapped to the Application Gateway public listener. | `string` | n/a | yes |
| <a name="input_agw_data_backend_host"></a> [agw\_data\_backend\_host](#input\_agw\_data\_backend\_host) | The target host header or FQDN expected by the Traefik ingress <br/>controller for routing. | `string` | n/a | yes |
| <a name="input_agw_data_public_hostname"></a> [agw\_data\_public\_hostname](#input\_agw\_data\_public\_hostname) | The public FQDN mapped to the Application Gateway public listener. | `string` | n/a | yes |
| <a name="input_agw_enable_dual_gateway"></a> [agw\_enable\_dual\_gateway](#input\_agw\_enable\_dual\_gateway) | Controls whether to share a single Application Gateway for NBS 7 <br/>  and NBS 6 traffic. When set to false, a separate gateway is required for<br/>  NBS 6 | `bool` | `true` | no |
| <a name="input_agw_key_vault_cert_name_private"></a> [agw\_key\_vault\_cert\_name\_private](#input\_agw\_key\_vault\_cert\_name\_private) | Name of the Key Vault secret that stores the private certificate | `string` | `null` | no |
| <a name="input_agw_key_vault_cert_name_public"></a> [agw\_key\_vault\_cert\_name\_public](#input\_agw\_key\_vault\_cert\_name\_public) | Name of the Key Vault secret that stores the public certificate | `string` | n/a | yes |
| <a name="input_agw_key_vault_cert_rg"></a> [agw\_key\_vault\_cert\_rg](#input\_agw\_key\_vault\_cert\_rg) | Key Vault Certificate Resource Group | `string` | n/a | yes |
| <a name="input_agw_nbs_ip_private"></a> [agw\_nbs\_ip\_private](#input\_agw\_nbs\_ip\_private) | Private IP address for the internal NBS 6 backend service target<br/>pool. | `string` | `null` | no |
| <a name="input_agw_nsg_akamai_ips"></a> [agw\_nsg\_akamai\_ips](#input\_agw\_nsg\_akamai\_ips) | List of Akamai IPs to allow inbound traffic on port 443. Supports<br/>    IPv4 addresses and CIDR blocks. | `list(string)` | `[]` | no |
| <a name="input_agw_private_backend_host"></a> [agw\_private\_backend\_host](#input\_agw\_private\_backend\_host) | The target backend host header/FQDN used for internal routing by<br/>    the Application Gateway. | `string` | `null` | no |
| <a name="input_agw_private_hostname"></a> [agw\_private\_hostname](#input\_agw\_private\_hostname) | The private FQDN mapped to the Application Gateway private listener | `string` | `null` | no |
| <a name="input_agw_private_ip"></a> [agw\_private\_ip](#input\_agw\_private\_ip) | The static private IP address assigned to the Application Gateway<br/>    frontend configuration. | `string` | `null` | no |
| <a name="input_agw_public_enabled"></a> [agw\_public\_enabled](#input\_agw\_public\_enabled) | Whether to have Terraform provision the resources from this module <br/>  in your Azure subscription | `bool` | `true` | no |
| <a name="input_agw_role_based_kv"></a> [agw\_role\_based\_kv](#input\_agw\_role\_based\_kv) | Specifies whether the Key Vault uses Azure Role-Based Access Control <br/>(RBAC) instead of access policies. | `bool` | `false` | no |
| <a name="input_agw_role_definition_name"></a> [agw\_role\_definition\_name](#input\_agw\_role\_definition\_name) | The Azure RBAC role definition name (e.g., 'Key Vault Secrets User') <br/>  assigned to the Application Gateway identity for secret access. | `string` | `""` | no |
| <a name="input_agw_subnet_name"></a> [agw\_subnet\_name](#input\_agw\_subnet\_name) | Subnet for Application Gateway deployment | `string` | n/a | yes |
| <a name="input_agw_vnet_name"></a> [agw\_vnet\_name](#input\_agw\_vnet\_name) | The name of the Azure Virtual Network (VNet) containing the <br/>  Application Gateway subnet. | `string` | n/a | yes |
| <a name="input_aks_agents_size"></a> [aks\_agents\_size](#input\_aks\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v7"` | no |
| <a name="input_aks_auto_scaling_enabled"></a> [aks\_auto\_scaling\_enabled](#input\_aks\_auto\_scaling\_enabled) | Enable node pool autoscaling | `bool` | `true` | no |
| <a name="input_aks_create_modern_subnet"></a> [aks\_create\_modern\_subnet](#input\_aks\_create\_modern\_subnet) | Creates a new subnet for the AKS cluster | `bool` | `false` | no |
| <a name="input_aks_default_node_pool_name"></a> [aks\_default\_node\_pool\_name](#input\_aks\_default\_node\_pool\_name) | This defines the default node pool names | `string` | `"systempool"` | no |
| <a name="input_aks_dns_zone_id"></a> [aks\_dns\_zone\_id](#input\_aks\_dns\_zone\_id) | Id for the associated DNS zone | `string` | `""` | no |
| <a name="input_aks_enable_cert_manager"></a> [aks\_enable\_cert\_manager](#input\_aks\_enable\_cert\_manager) | Create cert-manager helm release and associated Managed Identity | `bool` | `true` | no |
| <a name="input_aks_existing_modern_subnet_name"></a> [aks\_existing\_modern\_subnet\_name](#input\_aks\_existing\_modern\_subnet\_name) | Name of the existing aks subnet | `string` | `""` | no |
| <a name="input_aks_identity_type"></a> [aks\_identity\_type](#input\_aks\_identity\_type) | This defines the default value for identity type | `string` | `"UserAssigned"` | no |
| <a name="input_aks_k8_cluster_version"></a> [aks\_k8\_cluster\_version](#input\_aks\_k8\_cluster\_version) | Which Kubernetes release to use for the K8s cluster | `string` | `"1.35"` | no |
| <a name="input_aks_k8_orchestrator_version"></a> [aks\_k8\_orchestrator\_version](#input\_aks\_k8\_orchestrator\_version) | Which Kubernetes release to use for the nodes/agents in the default node pool of the K8s cluster | `string` | `"1.35"` | no |
| <a name="input_aks_modern_subnet"></a> [aks\_modern\_subnet](#input\_aks\_modern\_subnet) | n/a | `list(any)` | `[]` | no |
| <a name="input_aks_msi_id"></a> [aks\_msi\_id](#input\_aks\_msi\_id) | The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method. | `string` | `null` | no |
| <a name="input_aks_net_profile_dns_service_ip"></a> [aks\_net\_profile\_dns\_service\_ip](#input\_aks\_net\_profile\_dns\_service\_ip) | This defines the default value for the dns service IP address | `string` | `"10.96.0.10"` | no |
| <a name="input_aks_net_profile_service_cidr"></a> [aks\_net\_profile\_service\_cidr](#input\_aks\_net\_profile\_service\_cidr) | This defines the default value for the service CIDR | `string` | `"10.96.0.0/16"` | no |
| <a name="input_aks_network_profile_pod_cidr"></a> [aks\_network\_profile\_pod\_cidr](#input\_aks\_network\_profile\_pod\_cidr) | This defines the default value for pod CIDR | `string` | `"10.244.0.0/16"` | no |
| <a name="input_aks_node_count"></a> [aks\_node\_count](#input\_aks\_node\_count) | The initial quantity of nodes for the node pool. | `number` | `3` | no |
| <a name="input_aks_node_pool_disk_size_gb"></a> [aks\_node\_pool\_disk\_size\_gb](#input\_aks\_node\_pool\_disk\_size\_gb) | This defines the default node disk size | `number` | `30` | no |
| <a name="input_aks_node_pool_load_balancer_sku"></a> [aks\_node\_pool\_load\_balancer\_sku](#input\_aks\_node\_pool\_load\_balancer\_sku) | This defines load balancer sku | `string` | `"standard"` | no |
| <a name="input_aks_node_pool_max_count"></a> [aks\_node\_pool\_max\_count](#input\_aks\_node\_pool\_max\_count) | This defines the default node pool max count | `number` | `5` | no |
| <a name="input_aks_node_pool_min_count"></a> [aks\_node\_pool\_min\_count](#input\_aks\_node\_pool\_min\_count) | This defines the default node pool min count | `number` | `2` | no |
| <a name="input_aks_node_pool_network_plugin"></a> [aks\_node\_pool\_network\_plugin](#input\_aks\_node\_pool\_network\_plugin) | This defines the k8 network plugin | `string` | `"kubenet"` | no |
| <a name="input_aks_node_pool_type"></a> [aks\_node\_pool\_type](#input\_aks\_node\_pool\_type) | This defines the default node pool type | `string` | `"VirtualMachineScaleSets"` | no |
| <a name="input_aks_node_pool_vm_size"></a> [aks\_node\_pool\_vm\_size](#input\_aks\_node\_pool\_vm\_size) | This defines the node pool size | `string` | `"Standard_D2s_v7"` | no |
| <a name="input_aks_node_pool_zones"></a> [aks\_node\_pool\_zones](#input\_aks\_node\_pool\_zones) | AZs for the default node pool nodes | `list(any)` | <pre>[<br/>  1,<br/>  2,<br/>  3<br/>]</pre> | no |
| <a name="input_aks_os_sku"></a> [aks\_os\_sku](#input\_aks\_os\_sku) | Specifies the OS SKU used by the agent pool. Possible values include: <br/>`Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. <br/>If not specified, the default is `Ubuntu` if OSType=Linux or <br/>`Windows2019` if OSType=Windows. And the default Windows OSSKU <br/>will be changed to `Windows2022` after Windows2019 is deprecated. <br/>Changing this forces a new resource to be created. | `string` | `"Ubuntu2204"` | no |
| <a name="input_aks_rbac_aad_admin_group_object_ids"></a> [aks\_rbac\_aad\_admin\_group\_object\_ids](#input\_aks\_rbac\_aad\_admin\_group\_object\_ids) | List of group ids with access to the AKS cluster control plane | `list(string)` | n/a | yes |
| <a name="input_aks_resource_prefix"></a> [aks\_resource\_prefix](#input\_aks\_resource\_prefix) | Name to be used on all the resources as identifier. e.g. Project name, Application name | `string` | `""` | no |
| <a name="input_aks_subnet_name_aks"></a> [aks\_subnet\_name\_aks](#input\_aks\_subnet\_name\_aks) | Name of the aks subnet | `string` | `"csels-nbs-dev-low-modern-vnet-sn"` | no |
| <a name="input_aks_temporary_name_for_rotation"></a> [aks\_temporary\_name\_for\_rotation](#input\_aks\_temporary\_name\_for\_rotation) | This defines the default value for temp name for node rotation | `string` | `"tempnode"` | no |
| <a name="input_aks_user_node_pool_name"></a> [aks\_user\_node\_pool\_name](#input\_aks\_user\_node\_pool\_name) | This defines the default node pool names | `string` | `"userlnxpool"` | no |
| <a name="input_aks_vnet_name"></a> [aks\_vnet\_name](#input\_aks\_vnet\_name) | Name of the existing vnet | `string` | `"csels-nbs-dev-low-modern-vnet"` | no |
| <a name="input_create_datacompare_resources"></a> [create\_datacompare\_resources](#input\_create\_datacompare\_resources) | Create resources for DataCompare service? | `bool` | `false` | no |
| <a name="input_create_otel_collector_resources"></a> [create\_otel\_collector\_resources](#input\_create\_otel\_collector\_resources) | Create resources for OTEL Collector log export? | `bool` | `false` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the NBS 7 environment | `string` | n/a | yes |
| <a name="input_kafka_account_replication_type"></a> [kafka\_account\_replication\_type](#input\_kafka\_account\_replication\_type) | n/a | `string` | `"LRS"` | no |
| <a name="input_kafka_account_tier"></a> [kafka\_account\_tier](#input\_kafka\_account\_tier) | n/a | `string` | `"Standard"` | no |
| <a name="input_kafka_cluster_tier"></a> [kafka\_cluster\_tier](#input\_kafka\_cluster\_tier) | n/a | `string` | `"Standard"` | no |
| <a name="input_kafka_cluster_version"></a> [kafka\_cluster\_version](#input\_kafka\_cluster\_version) | n/a | `string` | `"5.1"` | no |
| <a name="input_kafka_component_version"></a> [kafka\_component\_version](#input\_kafka\_component\_version) | n/a | `string` | `"3.2"` | no |
| <a name="input_kafka_container_access_type"></a> [kafka\_container\_access\_type](#input\_kafka\_container\_access\_type) | n/a | `string` | `"private"` | no |
| <a name="input_kafka_destination_address_prefix"></a> [kafka\_destination\_address\_prefix](#input\_kafka\_destination\_address\_prefix) | n/a | `string` | `"VirtualNetwork"` | no |
| <a name="input_kafka_enabled"></a> [kafka\_enabled](#input\_kafka\_enabled) | Enable the module | `bool` | `true` | no |
| <a name="input_kafka_encryption_in_transit_enabled"></a> [kafka\_encryption\_in\_transit\_enabled](#input\_kafka\_encryption\_in\_transit\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_kafka_gtwy_password"></a> [kafka\_gtwy\_password](#input\_kafka\_gtwy\_password) | n/a | `string` | n/a | yes |
| <a name="input_kafka_gtwy_username"></a> [kafka\_gtwy\_username](#input\_kafka\_gtwy\_username) | n/a | `string` | n/a | yes |
| <a name="input_kafka_head_vm_size"></a> [kafka\_head\_vm\_size](#input\_kafka\_head\_vm\_size) | n/a | `string` | `"Standard_D2s_v7"` | no |
| <a name="input_kafka_infrastructure_encryption_enabled"></a> [kafka\_infrastructure\_encryption\_enabled](#input\_kafka\_infrastructure\_encryption\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_kafka_nat_gateway_enabled"></a> [kafka\_nat\_gateway\_enabled](#input\_kafka\_nat\_gateway\_enabled) | Enable NAT gateway to allow VM helath checks to reach the management api | `bool` | `true` | no |
| <a name="input_kafka_number_of_disks_per_node"></a> [kafka\_number\_of\_disks\_per\_node](#input\_kafka\_number\_of\_disks\_per\_node) | n/a | `number` | `1` | no |
| <a name="input_kafka_password"></a> [kafka\_password](#input\_kafka\_password) | n/a | `string` | n/a | yes |
| <a name="input_kafka_resource_prefix"></a> [kafka\_resource\_prefix](#input\_kafka\_resource\_prefix) | n/a | `string` | `""` | no |
| <a name="input_kafka_sg_name"></a> [kafka\_sg\_name](#input\_kafka\_sg\_name) | n/a | `string` | n/a | yes |
| <a name="input_kafka_storage_account_name"></a> [kafka\_storage\_account\_name](#input\_kafka\_storage\_account\_name) | n/a | `string` | n/a | yes |
| <a name="input_kafka_subnet_name"></a> [kafka\_subnet\_name](#input\_kafka\_subnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_kafka_tags"></a> [kafka\_tags](#input\_kafka\_tags) | n/a | `map(string)` | <pre>{<br/>  "createdby": "Terraform"<br/>}</pre> | no |
| <a name="input_kafka_target_instance_count"></a> [kafka\_target\_instance\_count](#input\_kafka\_target\_instance\_count) | n/a | `number` | `3` | no |
| <a name="input_kafka_tls_min_version"></a> [kafka\_tls\_min\_version](#input\_kafka\_tls\_min\_version) | n/a | `string` | `"1.2"` | no |
| <a name="input_kafka_username"></a> [kafka\_username](#input\_kafka\_username) | n/a | `string` | n/a | yes |
| <a name="input_kafka_worker_vm_size"></a> [kafka\_worker\_vm\_size](#input\_kafka\_worker\_vm\_size) | n/a | `string` | `"Standard_D2s_v7"` | no |
| <a name="input_kafka_zookeeper_vm_size"></a> [kafka\_zookeeper\_vm\_size](#input\_kafka\_zookeeper\_vm\_size) | n/a | `string` | `"Standard_D2s_v7"` | no |
| <a name="input_observability_grafana_major_version"></a> [observability\_grafana\_major\_version](#input\_observability\_grafana\_major\_version) | Major version number for Grafana | `string` | `"12"` | no |
| <a name="input_observability_resource_prefix"></a> [observability\_resource\_prefix](#input\_observability\_resource\_prefix) | Prefix for resource names | `string` | `""` | no |
| <a name="input_observability_update_admin_role_assignment"></a> [observability\_update\_admin\_role\_assignment](#input\_observability\_update\_admin\_role\_assignment) | Allow observability to give deployment role admin permissions to the grafana dashboard | `bool` | `true` | no |
| <a name="input_storage_account_account_kind"></a> [storage\_account\_account\_kind](#input\_storage\_account\_account\_kind) | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_storage_account_account_replication_type"></a> [storage\_account\_account\_replication\_type](#input\_storage\_account\_account\_replication\_type) | Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. | `string` | `"GRS"` | no |
| <a name="input_storage_account_account_tier"></a> [storage\_account\_account\_tier](#input\_storage\_account\_account\_tier) | Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. | `string` | `"Standard"` | no |
| <a name="input_storage_account_blob_container_delete_retention_days"></a> [storage\_account\_blob\_container\_delete\_retention\_days](#input\_storage\_account\_blob\_container\_delete\_retention\_days) | Number of days to retain soft delete containers. Default 7 days. | `number` | `7` | no |
| <a name="input_storage_account_blob_delete_retention_days"></a> [storage\_account\_blob\_delete\_retention\_days](#input\_storage\_account\_blob\_delete\_retention\_days) | Number of days to retain soft deleted blobs. Default 7 days. | `number` | `7` | no |
| <a name="input_storage_account_blob_private_ip_address"></a> [storage\_account\_blob\_private\_ip\_address](#input\_storage\_account\_blob\_private\_ip\_address) | Private IP address to set for storage account file endpoint. | `string` | `null` | no |
| <a name="input_storage_account_create_dns_record"></a> [storage\_account\_create\_dns\_record](#input\_storage\_account\_create\_dns\_record) | Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint. | `bool` | `false` | no |
| <a name="input_storage_account_dns_zone_id_blob"></a> [storage\_account\_dns\_zone\_id\_blob](#input\_storage\_account\_dns\_zone\_id\_blob) | Zone id of DNS to which record will be added for blob storage.(create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_storage_account_dns_zone_id_file"></a> [storage\_account\_dns\_zone\_id\_file](#input\_storage\_account\_dns\_zone\_id\_file) | Zone id of DNS to which record will be added for file storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_storage_account_dns_zone_name_blob"></a> [storage\_account\_dns\_zone\_name\_blob](#input\_storage\_account\_dns\_zone\_name\_blob) | Name of DNS zone to which record will be added for blob storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_storage_account_dns_zone_name_file"></a> [storage\_account\_dns\_zone\_name\_file](#input\_storage\_account\_dns\_zone\_name\_file) | Name of DNS zone to which record will be added for file storage. (create\_dns\_record must be true) | `string` | `""` | no |
| <a name="input_storage_account_file_private_ip_address"></a> [storage\_account\_file\_private\_ip\_address](#input\_storage\_account\_file\_private\_ip\_address) | Private IP address to set for storage account file endpoint. | `string` | `null` | no |
| <a name="input_storage_account_infrastructure_encryption_enabled"></a> [storage\_account\_infrastructure\_encryption\_enabled](#input\_storage\_account\_infrastructure\_encryption\_enabled) | Is infrastructure encryption enabled? | `bool` | `true` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only) | `string` | `"nbsstorageaccount"` | no |
| <a name="input_storage_account_public_network_access_enabled"></a> [storage\_account\_public\_network\_access\_enabled](#input\_storage\_account\_public\_network\_access\_enabled) | Whether the public network access is enabled? | `bool` | `false` | no |
| <a name="input_storage_account_subnet_name"></a> [storage\_account\_subnet\_name](#input\_storage\_account\_subnet\_name) | Name of subnet within virtual\_network\_name to be associated with storage account private endpoints. | `string` | n/a | yes |
| <a name="input_storage_dns_zone_virtual_network_name"></a> [storage\_dns\_zone\_virtual\_network\_name](#input\_storage\_dns\_zone\_virtual\_network\_name) | List of virtual network names to be associated as a virtual network link for the private dns zone. | `list(string)` | `[]` | no |
| <a name="input_vnet_location"></a> [vnet\_location](#input\_vnet\_location) | The Azure region | `string` | `"eastus"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the VNet created by Layer 0 | `string` | n/a | yes |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->