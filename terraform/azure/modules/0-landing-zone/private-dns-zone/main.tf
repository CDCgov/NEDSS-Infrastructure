resource "azurerm_private_dns_zone" "private" {
  count               = var.enabled ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# TODO: Given that each NBS 7 environment has its own VNet and its own Resource group, should the following resource always be created (regardless of the value of var.enabled)?
resource "azurerm_private_dns_zone_virtual_network_link" "private" {
  count                 = var.enabled ? 1 : 0
  name                  = "${var.vnet_name}-private-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private[count.index].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
}
