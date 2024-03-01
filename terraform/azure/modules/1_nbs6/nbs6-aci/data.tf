# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get App Gateway Subnet Data
data "azurerm_subnet" "appgw_subnet" {
  name                 = var.appgw_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

# Get ACI Subnet Data
data "azurerm_subnet" "aci_subnet" {
  name                 = var.aci_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}