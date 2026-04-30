module "nbs6-sqlmi" {
  source = "../../modules/1_nbs6/sqlmi"

  resource_prefix                    = var.sqlmi_resource_prefix
  sqlmi_resource_group_name          = var.sqlmi_resource_group_name
  sqlmi_vnet_name                    = var.sqlmi_vnet_name
  sqlmi_subnet_name                  = var.sqlmi_subnet_name
  sqlmi_key_vault                    = var.sqlmi_key_vault
  sqlmi_restoring_from_database_name = var.sqlmi_restoring_from_database_name
  sqlmi_restoring_from_database_rg   = var.sqlmi_restoring_from_database_rg
  sqlmi_restore_point_in_time        = var.sqlmi_restore_point_in_time
  sqlmi_vcore                        = var.sqlmi_vcore
  sqlmi_storage                      = var.sqlmi_storage
  sqlmi_sku_name                     = var.sqlmi_sku_name
  sqlmi_timezone_id                  = var.sqlmi_timezone_id
}
