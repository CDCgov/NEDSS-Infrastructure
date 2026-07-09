resource "azurerm_private_dns_a_record" "a" {
  count               = upper(var.record_type) == "A" ? 1 : 0
  name                = var.record_name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  records             = var.records
}

resource "azurerm_private_dns_cname_record" "cname" {
  count               = upper(var.record_type) == "CNAME" ? 1 : 0
  name                = var.record_name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  record              = var.cname_record
}