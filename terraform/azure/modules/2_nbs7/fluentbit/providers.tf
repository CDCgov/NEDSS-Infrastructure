terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~>2.12"
    }
  }
}

# When calling this module the helm provider must be passed and configured as shown below. 
# As an example, a data call is used for an exisiting AKS cluster. 

# data "azurerm_kubernetes_cluster" "main" {
#     name = "example_cluster_name"
#     resource_group_name = "example_resource_group_for_cluster"  
# }

# provider "azurerm" {
#   features {
#     resource_group{
#         prevent_deletion_if_contains_resources = false
#     }
#   }
# }

# provider "helm" {
#     kubernetes {
#         host                   = data.azurerm_kubernetes_cluster.main.kube_admin_config.0.host
#         username               = data.azurerm_kubernetes_cluster.main.kube_admin_config.0.username
#         password               = data.azurerm_kubernetes_cluster.main.kube_admin_config.0.password
#         client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate)
#         client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key)
#         cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate)
#     }
# }



