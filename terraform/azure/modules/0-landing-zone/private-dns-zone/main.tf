resource "azurerm_private_dns_zone" "private" {
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private" {
  name                  = "${var.vnet_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
}
