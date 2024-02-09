module "nbs-legacy" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/nbs-legacy?ref=CNPT-1628-alb-to-nlb"
 
  ami                    = var.ami
  instance_type          = var.instance_type
  private_subnet_ids     = data.aws_subnet.subnet_c.id
  public_subnet_ids      = module.legacy-vpc.public_subnets
  legacy_vpc_id          = module.legacy-vpc.vpc_id
  modern_vpc_id          = module.modernization-vpc.vpc_id
  shared_vpc_cidr_block  = var.shared_vpc_cidr_block
  legacy_resource_prefix = "cdc-nbs-legacy"
  ec2_key_name           = var.ec2_key_name
  db_instance_type       = var.db_instance_type
  db_snapshot_identifier = var.db_snapshot_identifier
  route53_url_name       = var.route53_url_name
  tags                   = var.tags
  ## conditional use dns if created or input zone_id otherwise
  zone_id     = local.zone_id
  domain_name = var.domain_name
  create_cert = var.create_cert
 
  artifacts_bucket_name          = var.artifacts_bucket_name
  deployment_package_key         = var.deployment_package_key
  nbs_db_dns                     = module.dns.nbs_db_dns
  kms_arn_shared_services_bucket = var.kms_arn_shared_services_bucket
  apply_immediately = true
}