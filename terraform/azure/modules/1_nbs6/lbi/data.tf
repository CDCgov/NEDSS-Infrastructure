# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name     = var.lbi_resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.lbi_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get Subnet Data
data "azurerm_subnet" "lbi_subnet" {
  name                 = var.lbi_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}