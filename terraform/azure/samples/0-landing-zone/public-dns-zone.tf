module "public_dns" { # Creates the public DNS zone in Azure portal in "DNS zones"
  source  = "../../modules/0-landing-zone/public-dns-zone"
  enabled = var.public_dns_zone_enabled

  public_domain_name  = var.public_domain_name
  resource_group_name = var.vnet_resource_group_name
}
