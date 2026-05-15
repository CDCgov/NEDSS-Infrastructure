# Get Client Config
data "azurerm_client_config" "current" {}

# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name = var.acr_resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.acr_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get App Gateway Subnet Data
data "azurerm_subnet" "acr_subnet" {
  name                 = var.acr_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}