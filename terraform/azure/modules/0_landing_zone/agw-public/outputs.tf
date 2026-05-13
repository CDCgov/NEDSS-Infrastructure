output "public_agw_id" {
  value = azurerm_application_gateway.agw_public.id
}

output "agw_public_ip" {
  value = azurerm_public_ip.agw_public_ip.ip_address
}