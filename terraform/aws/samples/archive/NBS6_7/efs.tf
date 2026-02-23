# Serial: 2025011501

module "efs" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/efs?ref=v1.2.23"
  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/efs"
  # SAMPLES
  #source  = "../app-infrastructure/efs"

  resource_prefix = var.resource_prefix
  vpc_id          = module.modernization-vpc.vpc_id
  vpc_cidrs       = module.modernization-vpc.private_subnets_cidr_blocks
  kms_key_arn     = module.kms.kms_key_arn

  mount_targets = { for k, v in toset(range(length(var.modern-azs))) :
    element(var.modern-azs, k) => { subnet_id = element(module.modernization-vpc.private_subnets, k) }
  }
}
