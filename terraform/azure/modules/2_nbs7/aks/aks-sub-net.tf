/*
//existing vnet
data "azurerm_virtual_network" "existing-vnet" {
  name                = "csels-nbs-dev-low-modern-vnet" #Need to create a var
  resource_group_name = var.modern_resource_group_name
}

resource "azurerm_subnet" "aks-default" {
  name                 = "${var.resource_prefix}-csels-nbs-dev-low-modern-vnet-sg" #Need to create a var
  virtual_network_name = data.azurerm_virtual_network.existing-vnet.name
  resource_group_name  = var.modern_resource_group_name
  address_prefixes     = var.modern_subnet 
}
*/

data "azurerm_virtual_network" "existing" {
  name                = "csels-nbs-dev-low-modern-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "new" {
  name                 = "csels-nbs-dev-low-modern-vnet-sn"
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = var.modern_subnet
}