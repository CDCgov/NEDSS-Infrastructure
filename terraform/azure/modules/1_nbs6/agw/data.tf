# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name     = var.agw_resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.agw_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get App Gateway Subnet Data
data "azurerm_subnet" "agw_subnet" {
  name                 = var.agw_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}