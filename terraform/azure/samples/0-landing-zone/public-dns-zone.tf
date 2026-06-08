module "public_dns" {
  source = "../../0_landing_zone/public-dns-zone"

  enabled             = var.enabled
  public_domain_name  = var.public_domain_name
  resource_group_name = var.resource_group_name
}
