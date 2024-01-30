module "efs" {
  source          = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/efs?ref=sgz-cdc-temp-test"
  resource_prefix = var.resource_prefix
  vpc_id          = data.aws_vpc.vpc_1.id
  vpc_cidrs       = local.list_subnet_cidr
  kms_key_arn     = module.kms.kms_key_arn

  mount_targets = { for k, v in toset(range(length(local.list_azs))) :
    element(local.list_azs, k) => { subnet_id = element(local.list_subnet_ids, k) }
  }
}
