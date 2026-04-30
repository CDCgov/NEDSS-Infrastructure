module "private_dns_zone" {
  source = "../../modules/2_nbs7/private-dns-zone"

  resource_group_name  = var.private_dns_resource_group_name
  virtual_network_name = var.private_dns_virtual_network_name
}
