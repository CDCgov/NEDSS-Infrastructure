data "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.environment}-aks"
  resource_group_name = var.resource_group_name
}