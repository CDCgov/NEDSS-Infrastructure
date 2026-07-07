module "storage_dns_zone" {
  source = "../../modules/2-nbs7/storage-dns-zone"

  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = [var.vnet_name]
}
