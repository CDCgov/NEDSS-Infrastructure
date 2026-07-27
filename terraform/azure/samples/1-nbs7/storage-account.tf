module "storage_account" {
  source = "../../modules/1-nbs7/storage-account"

  resource_group_name  = var.vnet_resource_group_name
  subnet_name          = var.storage_account_subnet_name
  virtual_network_name = var.vnet_name

  storage_account_name                 = var.storage_account_name
  account_kind                         = var.storage_account_account_kind
  account_tier                         = var.storage_account_account_tier
  create_dns_record                    = var.storage_account_create_dns_record
  blob_private_ip_address              = var.storage_account_blob_private_ip_address
  file_private_ip_address              = var.storage_account_file_private_ip_address
  account_replication_type             = var.storage_account_account_replication_type
  infrastructure_encryption_enabled    = var.storage_account_infrastructure_encryption_enabled
  public_network_access_enabled        = var.storage_account_public_network_access_enabled
  dns_zone_id_blob                     = var.storage_account_dns_zone_id_blob
  dns_zone_name_blob                   = var.storage_account_dns_zone_name_blob
  dns_zone_id_file                     = var.storage_account_dns_zone_id_file
  dns_zone_name_file                   = var.storage_account_dns_zone_name_file
  blob_delete_retention_days           = var.storage_account_blob_delete_retention_days
  blob_container_delete_retention_days = var.storage_account_blob_container_delete_retention_days

}
