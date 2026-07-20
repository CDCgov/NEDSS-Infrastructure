resource "azurerm_private_dns_zone" "private" {
  count = var.enabled ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private" {
  count = var.enabled ? 1 : 0

  name                  = "${var.vnet_name}-private-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private[count.index].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = var.registration_enabled
}

module "dns_records" {
  source   = "./modules/dns-record"
  for_each = var.dns_records

  resource_group_name = var.resource_group_name
  zone_name           = azurerm_private_dns_zone.private[0].name

  record_name  = each.value.record_name
  record_type  = each.value.record_type
  ttl          = each.value.ttl
  records      = each.value.records
  cname_record = each.value.cname_record
}
