resource "azurerm_dns_zone" "public" {
  count               = var.enabled ? 1 : 0
  name                = var.public_domain_name
  resource_group_name = var.resource_group_name
}

module "dns_records" {
  source   = "./modules/dns-record"
  for_each = var.dns_records

  resource_group_name = var.resource_group_name
  zone_name           = azurerm_private_dns_zone.private[0].name

  record_name  = each.value.record_name
  record_type  = each.value.record_type
  ttl          = try(each.value.ttl, null)
  records      = try(each.value.records, null)
  cname_record = try(each.value.cname_record, null)
}
