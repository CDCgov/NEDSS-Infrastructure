# Create Azure SQL Managed Instance
resource "azurerm_mssql_managed_instance" "sqlmi" {
  name                         = "${var.prefix}-sql-managed-instance"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  subnet_id                    = data.azurerm_subnet.sqlmi_subnet.id
  license_type                 = "LicenseIncluded"
  sku_name                     = "GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 128
  administrator_login          = var.sqlmi_username
  administrator_login_password = var.sqlmi_password

}

# Restore NBS_DataIngest Database
resource "azurerm_mssql_managed_database" "nbs_dataingest_db" {
  name                = "NBS_DataIngest"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

  lifecycle {
    prevent_destroy = false
  }
  point_in_time_restore {
    restore_point_in_time = var.restore_point_in_time
    source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_DataIngest"
  }
}

# Restore NBS_MSGOUTE Database
resource "azurerm_mssql_managed_database" "nbs_msgoute_db" {
  name                = "NBS_MSGOUTE"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

  lifecycle {
    prevent_destroy = false
  }
  point_in_time_restore {
    restore_point_in_time = var.restore_point_in_time
    source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_MSGOUTE"
  }
}

# Restore NBS_ODSE Database
resource "azurerm_mssql_managed_database" "nbs_odse_db" {
  name                = "NBS_ODSE"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

  lifecycle {
    prevent_destroy = false
  }
  point_in_time_restore {
    restore_point_in_time = var.restore_point_in_time
    source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_ODSE"
  }
}

# Restore NBS_SRTE Database
resource "azurerm_mssql_managed_database" "nbs_srte_db" {
  name                = "NBS_SRTE"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

  lifecycle {
    prevent_destroy = false
  }
  point_in_time_restore {
    restore_point_in_time = var.restore_point_in_time
    source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_SRTE"
  }
}

# Restore RDB Database
resource "azurerm_mssql_managed_database" "rdb_db" {
  name                = "RDB"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

  lifecycle {
    prevent_destroy = false
  }
  point_in_time_restore {
    restore_point_in_time = var.restore_point_in_time
    source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/RDB"
  }
}






