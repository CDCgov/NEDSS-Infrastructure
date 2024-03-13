
resource "azurerm_dashboard_grafana" "grafana" {
  name                = "${var.resource_prefix}-dashboard"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_kubernetes_cluster.main.location
  api_key_enabled                   = true

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.amw.id
  }

  depends_on = [ azurerm_monitor_workspace.amw ]

  #if already installed, this will still run successfully
  provisioner "local-exec" {
    command = "az extension add --name amg"
  }
  provisioner "local-exec" {
    command = "az grafana dashboard create --name ${var.resource_prefix}-dashboard --resource-group ${var.resource_group_name} --title NBS --definition @${path.module}/grafana-dashboard.json"
  }  
}

