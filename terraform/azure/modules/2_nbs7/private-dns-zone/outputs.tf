output "dns_zone_id_blob" {
  value = azurerm_private_dns_zone.private_dns_zone_blob.id
}

output "dns_zone_name_blob" {
  value = azurerm_private_dns_zone.private_dns_zone_blob.name
}

output "dns_zone_id_file" {
  value = azurerm_private_dns_zone.private_dns_zone_file.id
}

output "dns_zone_name_file" {
  value = azurerm_private_dns_zone.private_dns_zone_file.name
}
