# Serial: 2024081301

# #locals on whether to create route53 hosted zone
# locals {
#   #If create_route53_hosted_zone == true set value to 1 and create CSM, otherwise do not create
#   hosted_zone_count = var.create_route53_hosted_zone ? 1 : 0
# }

module "dns" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/dns?ref=release-7.11.0-rc1"
  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/development-infrastructure/dns"

  domain_name     = var.domain_name
  sub_domain_name = var.sub_domain_name
  # modern_vpc_id   = module.legacy-vpc.vpc_id
  legacy_vpc_id   = module.legacy-vpc.vpc_id
  # nbs_db_host_name    = module.nbs-legacy.nbs_db_address
  nbs_db_host_name    = module.rds.nbs_db_address
  nbs_db_dns          = var.nbs_db_dns
  tags                = var.tags
  hosted-zone-iam-arn = var.hosted-zone-iam-arn
  hosted-zone-id      = var.hosted-zone-id
}
