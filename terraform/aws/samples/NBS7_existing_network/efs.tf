module "efs" {
  source          = "../app-infrastructure/efs"
  resource_prefix = var.resource_prefix
#  vpc_id          = module.modernization-vpc.vpc_id
#  vpc_cidrs       = module.modernization-vpc.private_subnets_cidr_blocks
#  vpc_id          = var.modernization-vpc-id
#  vpc_cidrs       = var.modernization-vpc-private-subnets-cidr-blocks
  vpc_id          = data.aws_vpc.vpc_1.id
# may neet to tweak this to only get private
  vpc_cidrs       = local.list_subnet_cidr
  kms_key_arn     = module.kms.kms_key_arn

  #mount_targets = { for k, v in toset(range(length(var.modern-azs))) :
  #  element(var.modern-azs, k) => { subnet_id = element(module.modernization-vpc.private_subnets, k) }
  #}
  mount_targets = { for k, v in toset(range(length(local.list_azs))) :
    element(local.list_azs, k) => { subnet_id = element(local.list_subnet_ids, k) }
  }
}
