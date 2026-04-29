module "private_dns_zone" {
  source = "../../modules/2_nbs7/private-dns-zone"

  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}
