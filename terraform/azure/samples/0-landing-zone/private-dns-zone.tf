module "private_dns_zone" { # Creates resources in Azure portal in "Private DNS zones"
  source  = "../../modules/0-landing-zone/private-dns-zone"
  enabled = var.private_dns_zone_enabled

  resource_group_name   = var.vnet_resource_group_name
  private_dns_zone_name = var.private_domain_name
  vnet_name             = module.vnet.vnet_name
  vnet_id               = module.vnet.vnet_id
}
