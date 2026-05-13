resource "azurerm_subnet" "aks" {
  count                = var.create_modern_subnet ? 1 : 0
  name                 = var.subnet_name_aks
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = var.modern_subnet
}