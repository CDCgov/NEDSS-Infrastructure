# Terraform Azure Module: 1-nbs7/aks

## Description

This module is used to deploy and configure Azure Kubernetes Service (AKS) and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >=2.9.0, <3.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.9.0, <4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.14.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >=2.9.0, <3.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.9.0, <4.0.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aks"></a> [aks](#module\_aks) | git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/azure/modules/vendor/Azure/terraform-azurerm-aks/ | 942f77a605321c85abc73a243acd743c3eb99b37 |

### Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_action.ssh_public_key_gen](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azurerm_federated_identity_credential.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.data_compare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.aks_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cert_manager_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.data_compare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_container.data_compare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.data_compare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_id.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_pet.ssh_key_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_k8_cluster_version"></a> [k8\_cluster\_version](#input\_k8\_cluster\_version) | Which Kubernetes release to use for the K8s cluster | `string` | n/a | yes |
| <a name="input_k8_orchestrator_version"></a> [k8\_orchestrator\_version](#input\_k8\_orchestrator\_version) | Which Kubernetes release to use for the nodes/agents in the default node pool of the K8s cluster | `string` | n/a | yes |
| <a name="input_modern_resource_group_name"></a> [modern\_resource\_group\_name](#input\_modern\_resource\_group\_name) | This defines the modern resource group name | `string` | n/a | yes |
| <a name="input_rbac_aad_admin_group_object_ids"></a> [rbac\_aad\_admin\_group\_object\_ids](#input\_rbac\_aad\_admin\_group\_object\_ids) | List of group ids with access to the AKS cluster control plane | `list(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name to be used on all the resources as identifier. e.g. Project name, Application name | `string` | n/a | yes |
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_auto_scaling_enabled"></a> [auto\_scaling\_enabled](#input\_auto\_scaling\_enabled) | Enable node pool autoscaling | `bool` | `true` | no |
| <a name="input_create_datacompare_resources"></a> [create\_datacompare\_resources](#input\_create\_datacompare\_resources) | Create resources for DataCompare service? | `bool` | `false` | no |
| <a name="input_create_modern_subnet"></a> [create\_modern\_subnet](#input\_create\_modern\_subnet) | Creates a new subnet for the AKS cluster | `bool` | `false` | no |
| <a name="input_create_otel_collector_resources"></a> [create\_otel\_collector\_resources](#input\_create\_otel\_collector\_resources) | Create resources for OTEL Collector log export? | `bool` | `false` | no |
| <a name="input_datacompare_blob_container_name"></a> [datacompare\_blob\_container\_name](#input\_datacompare\_blob\_container\_name) | Name of blob container to be used for datacompare role. | `string` | `""` | no |
| <a name="input_datacompare_namespace_and_service"></a> [datacompare\_namespace\_and\_service](#input\_datacompare\_namespace\_and\_service) | List of Kubernetes namespace and services to be included in the datacompare federated credential | `map(any)` | <pre>{<br/>  "api": {<br/>    "namespace": "default",<br/>    "service": "data-compare-api-service"<br/>  },<br/>  "processor": {<br/>    "namespace": "default",<br/>    "service": "data-compare-processor-service"<br/>  }<br/>}</pre> | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | This defines the default node pool names | `string` | `"systempool"` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Id for the associated DNS zone | `string` | `""` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Create cert-manager helm release and associated Managed Identity | `bool` | `true` | no |
| <a name="input_existing_modern_subnet_name"></a> [existing\_modern\_subnet\_name](#input\_existing\_modern\_subnet\_name) | Name of the existing aks subnet | `string` | `""` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | This defines the default value for identity type | `string` | `"UserAssigned"` | no |
| <a name="input_k8_cluster_location"></a> [k8\_cluster\_location](#input\_k8\_cluster\_location) | This defines the default location for the k8 cluster | `string` | `"East US"` | no |
| <a name="input_modern_subnet"></a> [modern\_subnet](#input\_modern\_subnet) | Name of AKS subnet if it exists | `list(any)` | `[]` | no |
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
| <a name="input_os_sku"></a> [os\_sku](#input\_os\_sku) | Specifies the OS SKU used by the agent pool. Possible values include: <br/>`Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. <br/>If not specified, the default is `Ubuntu` if OSType=Linux or <br/>`Windows2019` if OSType=Windows. And the default Windows OSSKU <br/>will be changed to `Windows2022` after Windows2019 is deprecated. <br/>Changing this forces a new resource to be created. | `string` | `"Ubuntu2204"` | no |
| <a name="input_otel_collector_blob_container_name"></a> [otel\_collector\_blob\_container\_name](#input\_otel\_collector\_blob\_container\_name) | Name of blob container to be used for OTEL Collector log storage. | `string` | `""` | no |
| <a name="input_otel_collector_namespace_and_service"></a> [otel\_collector\_namespace\_and\_service](#input\_otel\_collector\_namespace\_and\_service) | List of Kubernetes namespace and service for the OTEL Collector federated credential | `map(any)` | <pre>{<br/>  "collector": {<br/>    "namespace": "observability",<br/>    "service": "splunk-otel-collector"<br/>  }<br/>}</pre> | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Location of the resource group. | `string` | `"eastus"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only) | `string` | `"nbsstorageaccount"` | no |
| <a name="input_subnet_name_aks"></a> [subnet\_name\_aks](#input\_subnet\_name\_aks) | Name of the aks subnet | `string` | `"csels-nbs-dev-low-modern-vnet-sn"` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | This defines the default value for temp name for node rotation | `string` | `"tempnode"` | no |
| <a name="input_user_node_pool_name"></a> [user\_node\_pool\_name](#input\_user\_node\_pool\_name) | This defines the default node pool names | `string` | `"userlnxpool"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the existing vnet | `string` | `"csels-nbs-dev-low-modern-vnet"` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_data_compare_identity_client_id"></a> [data\_compare\_identity\_client\_id](#output\_data\_compare\_identity\_client\_id) | Client ID to set as the azure.workload.identity/client-id annotation on the Kubernetes service account. |
| <a name="output_key_data"></a> [key\_data](#output\_key\_data) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_kubelet_identity_id"></a> [kubelet\_identity\_id](#output\_kubelet\_identity\_id) | n/a |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | n/a |
<!-- END_TF_DOCS -->
