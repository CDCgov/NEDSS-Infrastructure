output "public_agw_id" {
  value = try(azurerm_application_gateway.agw_public[0].id, null)
}

output "agw_public_ip" {
  value = try(azurerm_public_ip.agw_public_ip[0].ip_address, null)
}