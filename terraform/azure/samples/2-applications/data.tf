data "azurerm_kubernetes_cluster" "aks" {
  name                = var.linkerd_aks_cluster_name
  resource_group_name = var.vnet_resource_group_name
}