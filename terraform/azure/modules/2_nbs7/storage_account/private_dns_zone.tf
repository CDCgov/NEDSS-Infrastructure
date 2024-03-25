data "azurerm_virtual_network" "vnet" {
    name = var.virtual_network_name
    resource_group_name = var.resource_group_name
}
 
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_blob" {
  name                  = "${var.storage_account_name}-blob"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = var.dns_zone_name_blob
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_file" {
  name                  = "${var.storage_account_name}-file"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = var.dns_zone_name_file
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}