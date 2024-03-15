# data "azurerm_resource_group" "rg" {
#   name = "csels-nbs-dev-low-rg"
# }

# data "azurerm_kubernetes_cluster" "aks_cluster" {
#   name                = var.aks_cluster_name
#   resource_group_name = var.resource_group_name
# }

# data "azurerm_kubernetes_cluster" "aks_cluster_auth" {
#   name                = data.azurerm_kubernetes_cluster.aks_cluster.name
#   resource_group_name = data.azurerm_kubernetes_cluster.aks_cluster.resource_group_name

# #   kube_config {
# #     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
# #     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
# #     client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
# #     host                   = data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
# #     password               = var.service_principal_client_secret
# #     username               = var.service_principal_client_id
# #   }
# }