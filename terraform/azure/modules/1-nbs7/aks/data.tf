data "azurerm_resource_group" "rg" {
  name = var.modern_resource_group_name
}

data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "aks" {
  count                = var.create_modern_subnet ? 0 : 1
  name                 = var.existing_modern_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

