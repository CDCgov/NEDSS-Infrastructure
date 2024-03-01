output "managed_instance_id" {
  value = azurerm_mssql_managed_instance.sqlmi.id
}

output "managed_instance_fqdn" {
  value = azurerm_mssql_managed_instance.sqlmi.fqdn
}

output "nbs_dataingest_db_id" {
  value = azurerm_mssql_managed_database.nbs_msgoute_db.id
}

output "nbs_msgoute_db_id" {
  value = azurerm_mssql_managed_database.nbs_msgoute_db.id
}

output "nbs_odse_db_id" {
  value = azurerm_mssql_managed_database.nbs_odse_db.id
}

output "nbs_srte_db_id" {
  value = azurerm_mssql_managed_database.nbs_srte_db.id
}

output "rdb_db_id" {
  value = azurerm_mssql_managed_database.rdb_db.id
}