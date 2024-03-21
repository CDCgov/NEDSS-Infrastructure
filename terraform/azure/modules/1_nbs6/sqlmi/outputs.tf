output "managed_instance_id" {
  value = azurerm_mssql_managed_instance.sqlmi.id
}

output "managed_instance_fqdn" {
  value = azurerm_mssql_managed_instance.sqlmi.fqdn
}