<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.3 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >=2.9.0, <3.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.9.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >=2.9.0, <3.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/aks/azurerm | 11.5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_action.ssh_public_key_gen](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_id.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_pet.ssh_key_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create_modern_subnet"></a> [create\_modern\_subnet](#input\_create\_modern\_subnet) | Creates a new subnet for the AKS cluster | `bool` | `false` | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | This defines the default node pool names | `string` | `"systempool"` | no |
| <a name="input_existing_modern_subnet_name"></a> [existing\_modern\_subnet\_name](#input\_existing\_modern\_subnet\_name) | Name of the existing aks subnet | `string` | `""` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | This defines the default value for identity type | `string` | `"UserAssigned"` | no |
| <a name="input_k8_cluster_location"></a> [k8\_cluster\_location](#input\_k8\_cluster\_location) | This defines the default location for the k8 cluster | `string` | `"East US"` | no |
| <a name="input_k8_cluster_version"></a> [k8\_cluster\_version](#input\_k8\_cluster\_version) | This defines the version of the k8 cluster | `string` | n/a | yes |
| <a name="input_modern_resource_group_name"></a> [modern\_resource\_group\_name](#input\_modern\_resource\_group\_name) | This defines the modern resource group name | `string` | n/a | yes |
| <a name="input_modern_subnet"></a> [modern\_subnet](#input\_modern\_subnet) | n/a | `list(any)` | `[]` | no |
| <a name="input_msi_id"></a> [msi\_id](#input\_msi\_id) | The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method. | `string` | `null` | no |
| <a name="input_net_profile_dns_service_ip"></a> [net\_profile\_dns\_service\_ip](#input\_net\_profile\_dns\_service\_ip) | This defines the default value for the dns service IP address | `string` | `"10.96.0.10"` | no |
| <a name="input_net_profile_service_cidr"></a> [net\_profile\_service\_cidr](#input\_net\_profile\_service\_cidr) | This defines the default value for the service CIDR | `string` | `"10.96.0.0/16"` | no |
| <a name="input_network_profile_pod_cidr"></a> [network\_profile\_pod\_cidr](#input\_network\_profile\_pod\_cidr) | This defines the default value for pod CIDR | `string` | `"10.244.0.0/16"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The initial quantity of nodes for the node pool. | `number` | `3` | no |
| <a name="input_node_pool_disk_size_gb"></a> [node\_pool\_disk\_size\_gb](#input\_node\_pool\_disk\_size\_gb) | This defines the default node disk size | `number` | `30` | no |
| <a name="input_node_pool_load_balancer_sku"></a> [node\_pool\_load\_balancer\_sku](#input\_node\_pool\_load\_balancer\_sku) | This defines load balancer sku | `string` | `"standard"` | no |
| <a name="input_node_pool_max_count"></a> [node\_pool\_max\_count](#input\_node\_pool\_max\_count) | This defines the default node pool max count | `number` | `5` | no |
| <a name="input_node_pool_min_count"></a> [node\_pool\_min\_count](#input\_node\_pool\_min\_count) | This defines the default node pool min count | `number` | `2` | no |
| <a name="input_node_pool_network_plugin"></a> [node\_pool\_network\_plugin](#input\_node\_pool\_network\_plugin) | This defines the k8 network plugin | `string` | `"kubenet"` | no |
| <a name="input_node_pool_type"></a> [node\_pool\_type](#input\_node\_pool\_type) | This defines the default node pool type | `string` | `"VirtualMachineScaleSets"` | no |
| <a name="input_node_pool_vm_size"></a> [node\_pool\_vm\_size](#input\_node\_pool\_vm\_size) | This defines the node pool size | `string` | `"Standard_DS2_v4"` | no |
| <a name="input_node_pool_zones"></a> [node\_pool\_zones](#input\_node\_pool\_zones) | AZs for the default node pool nodes | `list(any)` | <pre>[<br/>  1,<br/>  2,<br/>  3<br/>]</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | (See `node_pools` in `./variables.tf`. ) | map of objects | `{}` | no |
| <a name="input_os_sku"></a> [os\_sku](#input\_os\_sku) | Specifies the OS SKU used by the agent pool. Possible values include: <br/>`Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. <br/>If not specified, the default is `Ubuntu` if OSType=Linux or <br/>`Windows2019` if OSType=Windows. And the default Windows OSSKU <br/>will be changed to `Windows2022` after Windows2019 is deprecated. <br/>Changing this forces a new resource to be created. | `string` | `"Ubuntu2204"` | no |
| <a name="input_rbac_aad_admin_group_object_ids"></a> [rbac\_aad\_admin\_group\_object\_ids](#input\_rbac\_aad\_admin\_group\_object\_ids) | List of group ids with access to the AKS cluster control plane | `list(string)` | n/a | yes |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Location of the resource group. | `string` | `"eastus"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name to be used on all the resources as identifier. e.g. Project name, Application name | `string` | n/a | yes |
| <a name="input_subnet_name_aks"></a> [subnet\_name\_aks](#input\_subnet\_name\_aks) | Name of the aks subnet | `string` | `"csels-nbs-dev-low-modern-vnet-sn"` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | This defines the default value for temp name for node rotation | `string` | `"tempnode"` | no |
| <a name="input_user_node_pool_name"></a> [user\_node\_pool\_name](#input\_user\_node\_pool\_name) | This defines the default node pool names | `string` | `"userlnxpool"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the existing vnet | `string` | `"csels-nbs-dev-low-modern-vnet"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_key_data"></a> [key\_data](#output\_key\_data) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_kubelet_identity_id"></a> [kubelet\_identity\_id](#output\_kubelet\_identity\_id) | n/a |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | n/a |
<!-- END_TF_DOCS -->
