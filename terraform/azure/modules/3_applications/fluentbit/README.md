# Terraform Deployment of Fluenbit to Azure Kubernetes services (AKS)

## Description

This module is used to deploy and configure Fluenbit to Azure Kubernetes services (AKS). 

## Prerequisites
The fluentbit module requires some Azure resource to exist before this module can be sucessfully deployed.
1. A storage account to which logs are dumped
2. An AKS cluster

## Required providers
The fluenbit module requires the following providers. For deploying to an existing AKS cluster see the code snippet under the [Helm Provider](#helm-provider) section.
1. azurerm
2. helm

### Helm Provider
```
data "azurerm_kubernetes_cluster" "main" {
    name = "example_cluster_name"
    resource_group_name = "example_resource_group_for_cluster"  
}

provider "helm" {
    kubernetes = {
        host                   = data.azurerm_kubernetes_cluster.main.kube_config[0].host
        username               = data.azurerm_kubernetes_cluster.main.kube_config[0].username
        password               = data.azurerm_kubernetes_cluster.main.kube_config[0].password
        client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
        client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
        cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
    }
}
```

## Inputs

Below are the input parameter variables for the eks-nbs:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| azure_container_name | string | fluentbit-logs | Name of azure container to create and store fluenbit application logs. |
| blob_account_name | string |  | Azure account name for blob storage (sensitive) |
| blob_shared_key | string |  | Azure shared key for blob storage access (sensitive) |
| helm_version | string | 0.43.0 | Version of fluentbit helm chart to deploy |
| namespace | string | observability | Kubernetes namespace for fluentbit resources |
| resource_prefix | string | cdc-nbs | Prefix for resource names |


## Outputs

There are no referenceable outputs from this module.

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

- There are no external module dependencies

