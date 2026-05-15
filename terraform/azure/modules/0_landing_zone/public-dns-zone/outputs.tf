output "dns_zone_id" {
  value = try(azurerm_dns_zone.public[0].id, "Module not enabled")
}

