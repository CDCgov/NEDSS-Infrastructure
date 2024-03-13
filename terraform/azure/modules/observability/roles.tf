# give deployment user data read permissions
resource "azurerm_role_assignment" "datareaderrole" {
  scope              = azurerm_monitor_workspace.amw.id
  role_definition_id = "/subscriptions/${split("/", azurerm_monitor_workspace.amw.id)[2]}/providers/Microsoft.Authorization/roleDefinitions/b0d8363b-8ddd-447d-831f-62ca05bff136"
  principal_id       = azurerm_dashboard_grafana.grafana.identity.0.principal_id
}

# give deployment grafana resource group read permissions
resource "azurerm_role_assignment" "user_readerrole" {
  scope              = data.azurerm_resource_group.main.id
  role_definition_id = "/subscriptions/${split("/", azurerm_monitor_workspace.amw.id)[2]}/providers/Microsoft.Authorization/roleDefinitions/43d0d8ad-25c7-4714-9337-8ba259a9fe05"
  principal_id       = azurerm_dashboard_grafana.grafana.identity.0.principal_id
}

#grafana admin role
resource "azurerm_role_assignment" "user_adminrole" {
  count = var.update_admin_role_assignment ? 1 : 0
  scope              = data.azurerm_resource_group.main.id
  role_definition_id = "/subscriptions/${split("/", azurerm_monitor_workspace.amw.id)[2]}/providers/Microsoft.Authorization/roleDefinitions/22926164-76b3-42b3-bc55-97df8dab3e41"
  principal_id       = data.azurerm_client_config.current.object_id
}