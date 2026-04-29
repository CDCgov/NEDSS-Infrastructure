module "storage_account" {
  source = "../../modules/2_nbs7/storage-account"

  resource_group_name  = var.resource_group_name
  subnet_name          = var.subnet_name
  virtual_network_name = var.virtual_network_name
}
