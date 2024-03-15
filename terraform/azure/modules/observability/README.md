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
    - The cluster *must* use **managed identity authentication**.
    

## Required providers
The observability module requires the following providers. For deploying to an existing AKS cluster see the code snippet under the [Helm Provider](#helm-provider) section.
1. azurerm

## Inputs

Below are the input parameter variables for the eks-nbs:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| cluster_name | string |  | Name of AKS cluster for which monitoring will be set up |
| resource_group_name | string |  | Resource group name for existing and to be deployed azure resources |
| resource_prefix | string | cdc-nbs | Prefix for resource names |
| update_admin_role_assignment | string |  | Allow observability to give deployment role admin permissions to the grafana dashboard |


## Outputs

There are no referenceable outputs from this module.

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

- There are no external module dependencies

