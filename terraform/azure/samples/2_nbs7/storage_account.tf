module "storage_account" {
  source = "../../modules/2_nbs7/storage-account"

  resource_group_name  = var.storage_account_resource_group_name
  subnet_name          = var.storage_account_subnet_name
  virtual_network_name = var.storage_account_virtual_network_name
}
