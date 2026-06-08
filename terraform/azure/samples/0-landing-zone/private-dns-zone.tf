module "private_dns_zone" {
  source = "../../0_landing_zone/private-dns-zone"

  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  vnet_name             = module.vnet.vnet_name
  vnet_id               = module.vnet.vnet_id
}
