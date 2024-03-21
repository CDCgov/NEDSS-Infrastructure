# Create Azure SQL Managed Instance
# NOTE: https://learn.microsoft.com/en-us/azure/azure-sql/database/long-term-retention-overview?view=azuresql
# https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/automated-backups-overview?view=azuresql
# If you delete a managed instance, all databases on that managed instance are also deleted and can't be recovered. 
# You can't restore a deleted managed instance. But if you've configured long-term retention for a managed instance, 
# LTR backups are not deleted. You can then use those backups to restore databases to a different managed instance 
# in the same subscription, to a point in time when an LTR backup was taken. To learn more, review Restore long-term backup.

# Create Random Username and Password
resource "random_string" "sqlmi_username" {
  length           = 16
  special          = false
}

resource "random_password" "sqlmi_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store in Key Vault
resource "azurerm_key_vault_secret" "sqlmi_username_secret" {
  name         = "${var.prefix}-sqlmi-username"
  value        = random_string.sqlmi_username.result
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "sqlmi_password_secret" {
  name         = "${var.prefix}-sqlmi-password"
  value        = random_password.sqlmi_password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

# Create Azure SQL Managed Instance
resource "azurerm_mssql_managed_instance" "sqlmi" {
  name                         = "${var.prefix}-sql-managed-instance"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  subnet_id                    = data.azurerm_subnet.sqlmi_subnet.id
  license_type                 = "LicenseIncluded"
  sku_name                     = var.sqlmi_sku_name
  vcores                       = var.sqlmi_vcore
  storage_size_in_gb           = var.sqlmi_storage
  administrator_login          = random_string.sqlmi_username.result
  administrator_login_password = random_password.sqlmi_password.result
  lifecycle {
    ignore_changes = [ 
      tags["business_steward"],
      tags["center"],
      tags["environment"],
      tags["escid"],
      tags["funding_source"],
      tags["pii_data"],
      tags["security_compliance"],
      tags["security_steward"],
      tags["support_group"],
      tags["system"],
      tags["technical_poc"],
      tags["technical_steward"],
      tags["zone"]
      ]
    }
}

# # Restore NBS_DataIngest Database
# resource "azurerm_mssql_managed_database" "nbs_dataingest_db" {
#   name                = "NBS_DataIngest"
#   managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

#   lifecycle {
#     prevent_destroy = false
#   }
#   long_term_retention_policy {
#     weekly_retention  = "P2W"
#     week_of_year      = null
#   }
#   point_in_time_restore {
#     restore_point_in_time = var.sqlmi_restore_point_in_time
#     source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_DataIngest"
#   }
# }

# # Restore NBS_MSGOUTE Database
# resource "azurerm_mssql_managed_database" "nbs_msgoute_db" {
#   name                = "NBS_MSGOUTE"
#   managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id
 

#   lifecycle {
#     prevent_destroy = false
#   }
#   long_term_retention_policy {
#     weekly_retention  = "P2W"
#     week_of_year      = null
#   }
#   point_in_time_restore {
#     restore_point_in_time = var.sqlmi_restore_point_in_time
#     source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_MSGOUTE"
#   }
# }

# # Restore NBS_ODSE Database
# resource "azurerm_mssql_managed_database" "nbs_odse_db" {
#   name                = "NBS_ODSE"
#   managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

#   lifecycle {
#     prevent_destroy = false
#   }
#   long_term_retention_policy {
#     weekly_retention  = "P2W"
#     week_of_year      = null
#   }
#   point_in_time_restore {
#     restore_point_in_time = var.sqlmi_restore_point_in_time
#     source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_ODSE"
#   }
# }

# # Restore NBS_SRTE Database
# resource "azurerm_mssql_managed_database" "nbs_srte_db" {
#   name                = "NBS_SRTE"
#   managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

#   lifecycle {
#     prevent_destroy = false
#   }
#   long_term_retention_policy {
#     weekly_retention  = "P2W"
#     week_of_year      = null
#   }
#   point_in_time_restore {
#     restore_point_in_time = var.sqlmi_restore_point_in_time
#     source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/NBS_SRTE"
#   }
# }

# # Restore RDB Database
# resource "azurerm_mssql_managed_database" "rdb_db" {
#   name                = "RDB"
#   managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id

#   lifecycle {
#     prevent_destroy = false
#   }
#   long_term_retention_policy {
#     weekly_retention  = "P2W"
#     week_of_year      = null
#   }
#   point_in_time_restore {
#     restore_point_in_time = var.sqlmi_restore_point_in_time
#     source_database_id = "${data.azurerm_mssql_managed_instance.restore_from_database.id}/databases/RDB"
#   }
# }






