output "appgw_id" {
  value = azurerm_application_gateway.appgw.id
}

output "aci_id" {
  value = azurerm_container_group.aci.id
}