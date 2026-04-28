resource "azurerm_subnet" "new" {
  name                 = var.subnet_name_new
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = var.modern_subnet
}