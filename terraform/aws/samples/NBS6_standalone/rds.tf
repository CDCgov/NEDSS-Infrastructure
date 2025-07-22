# Serial: 2025071001

module "rds" {

  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/rds?ref=release-7.11.0-rc1"

  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/development-infrastructure/rds"

  db_instance_type            = var.db_instance_type
  db_snapshot_identifier      = var.db_snapshot_identifier
  private_subnet_ids          = module.legacy-vpc.private_subnets
  manage_master_user_password = var.manage_master_user_password
  app_security_group_id       = module.nbs-legacy.security_group_id
  # ingress_vpc_cidr_blocks     = "${var.modern-cidr},${var.legacy-cidr},${var.shared_vpc_cidr_block}"
  ingress_vpc_cidr_blocks     = "${var.legacy-cidr},${var.shared_vpc_cidr_block}"

  vpc_id                      = module.legacy-vpc.vpc_id
  resource_prefix             = var.resource_prefix

}
