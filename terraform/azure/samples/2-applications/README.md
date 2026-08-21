# Terraform Module Layer: 2-applications

## Description

This Terraform module layer provisions applications being deployed to Kubernetes and expects certain upstream infrastructure
to already exist (VNet, subnets, RBAC, Azure AKS etc.). This README explains how those dependencies are referenced.

## 🧭 Purpose & Scope

This module:

- Does not create foundational infrastructure
- Consumes upstream resources via data sources or inputs
- Is intended to be used after core NBS 7 layers

Typical usage:

- 0-landing-zone → 1-nbs7 → **2-applications \(this module)**
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites

- Terraform >= 1.15.6
- Azure CLI configured
- Access to required Azure subscriptions
- Network connection if Kuberentes cluster is has its API endpoint set to private

## 🔗 Upstream Dependencies

- A Kubernetes cluster must already exist

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |

### Providers

| Name                                                         | Version      |
| ------------------------------------------------------------ | ------------ |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=4.68, <5.0 |

### Modules

| Name                                                     | Source                               | Version |
| -------------------------------------------------------- | ------------------------------------ | ------- |
| <a name="module_linkerd"></a> [linkerd](#module_linkerd) | ../../modules/2-applications/linkerd | n/a     |

### Resources

| Name                                                                                                                                    | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |

### Inputs

| Name                                                                                                            | Description                               | Type     | Default                            | Required |
| --------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | -------- | ---------------------------------- | :------: |
| <a name="input_environment_name"></a> [environment_name](#input_environment_name)                               | The name of the NBS 7 environment         | `string` | n/a                                |   yes    |
| <a name="input_vnet_resource_group_name"></a> [vnet_resource_group_name](#input_vnet_resource_group_name)       | The name of the resource group            | `string` | n/a                                |   yes    |
| <a name="input_linkerd_aks_cluster_name"></a> [linkerd_aks_cluster_name](#input_linkerd_aks_cluster_name)       | Name of the AKS cluster                   | `string` | `"dev-aks"`                        |    no    |
| <a name="input_linkerd_chart"></a> [linkerd_chart](#input_linkerd_chart)                                        | Name of linkerd chart                     | `string` | `"linkerd-crds"`                   |    no    |
| <a name="input_linkerd_controlplane_chart"></a> [linkerd_controlplane_chart](#input_linkerd_controlplane_chart) | Name of linkerd control plane chart       | `string` | `"linkerd-control-plane"`          |    no    |
| <a name="input_linkerd_create_linkerd_viz"></a> [linkerd_create_linkerd_viz](#input_linkerd_create_linkerd_viz) | Whether to install linkerd viz            | `bool`   | `true`                             |    no    |
| <a name="input_linkerd_namespace_name"></a> [linkerd_namespace_name](#input_linkerd_namespace_name)             | Name of linkerd namespace                 | `string` | `"linkerd"`                        |    no    |
| <a name="input_linkerd_repository"></a> [linkerd_repository](#input_linkerd_repository)                         | Repository to use when installing linkerd | `string` | `"https://helm.linkerd.io/stable"` |    no    |
| <a name="input_linkerd_viz_chart"></a> [linkerd_viz_chart](#input_linkerd_viz_chart)                            | Name of linkerd viz chart                 | `string` | `"linkerd-viz"`                    |    no    |
| <a name="input_linkerd_viz_namespace_name"></a> [linkerd_viz_namespace_name](#input_linkerd_viz_namespace_name) | Name of linkerd viz namespace             | `string` | `"linkerd-viz"`                    |    no    |

<!-- END_TF_DOCS -->
