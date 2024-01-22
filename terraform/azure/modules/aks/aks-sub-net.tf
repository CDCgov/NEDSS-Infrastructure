
//existing vnet
data "azurerm_virtual_network" "existing-vnet" {
  name                = "csels-nbs-dev-low-modern-vnet" #Need to create a var
  resource_group_name = var.modern_resource_group_name
}

resource "azurerm_subnet" "aks-default" {
  name                 = "csels-nbs-dev-low-modern-vnet-aks-sg" #Need to create a var
  virtual_network_name = data.azurerm_virtual_network.existing-vnet.name
  resource_group_name  = var.modern_resource_group_name
  address_prefixes     = var.modern_subnet 
}