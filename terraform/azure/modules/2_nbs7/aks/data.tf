data "azurerm_resource_group" "rg" {
  name = var.modern_resource_group_name
}

data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

