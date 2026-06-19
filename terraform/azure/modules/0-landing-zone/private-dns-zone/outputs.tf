output "private_dns_zone_id" {
  value = try(azurerm_private_dns_zone.private[0].id, "Module not enabled")
}
