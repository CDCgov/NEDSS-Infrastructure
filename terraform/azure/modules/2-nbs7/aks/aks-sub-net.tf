resource "azurerm_subnet" "aks" {
  count                = var.create_modern_subnet ? 1 : 0
  name                 = var.subnet_name_aks
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = var.modern_subnet
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = try(azurerm_subnet.aks[0].id, data.azurerm_subnet.aks[0].id)
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}