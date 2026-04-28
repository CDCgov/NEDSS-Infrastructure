# Terraform Deployment of Fluenbit to Azure Kubernetes services (AKS)

## Description

This module is used to deploy and configure the observability module and onboard it to an existing Azure Kubernetes services (AKS). The observability stack consists of Azure Monitor, Azure Managed Prometheus, and Azure Managed Grafana

## Prerequisites

The fluentbit module requires some Azure resource to exist before this module can be sucessfully deployed.

1. An AKS cluster
2. Azure CLI is required for the grafana dashboard configuration (https://learn.microsoft.com/en-us/cli/azure/).
3. The proper permissions on the role used to deploy resources
   - You require at least **Contributor** access to the cluster for onboarding.
   - You require **Monitoring Reader** or **Monitoring Contributor** to view data after monitoring is enabled.
4. Managed Prometheus prerequisites
   - The cluster _must_ use **managed identity authentication**.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                               | Version |
| ------------------------------------------------------------------ | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~>4.0   |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>4.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                     | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_dashboard_grafana.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana)                                                                   | resource    |
| [azurerm_monitor_alert_prometheus_rule_group.amp_rule_group_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group)              | resource    |
| [azurerm_monitor_alert_prometheus_rule_group.kubernetes_recording_rules_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource    |
| [azurerm_monitor_alert_prometheus_rule_group.node_recording_rules_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group)       | resource    |
| [azurerm_monitor_data_collection_endpoint.dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint)                                         | resource    |
| [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule)                                                 | resource    |
| [azurerm_monitor_data_collection_rule_association.dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association)                        | resource    |
| [azurerm_monitor_workspace.amw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_workspace)                                                                       | resource    |
| [azurerm_role_assignment.datareaderrole](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                | resource    |
| [azurerm_role_assignment.user_adminrole](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                | resource    |
| [azurerm_role_assignment.user_readerrole](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                               | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                                                        | data source |
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster)                                                                 | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                                         | data source |

## Inputs

| Name                                                                                                                  | Description                                                                            | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                                                 | Name of AKS cluster for which monitoring will be set up                                | `string` | n/a     |   yes    |
| <a name="input_grafana_major_version"></a> [grafana_major_version](#input_grafana_major_version)                      | Major version number for Grafana                                                       | `string` | `"12"`  |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                            | Resource group name for existing and to be deployed azure resources                    | `string` | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                        | Prefix for resource names                                                              | `string` | `"nbs"` |    no    |
| <a name="input_update_admin_role_assignment"></a> [update_admin_role_assignment](#input_update_admin_role_assignment) | Allow observability to give deployment role admin permissions to the grafana dashboard | `bool`   | `true`  |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
