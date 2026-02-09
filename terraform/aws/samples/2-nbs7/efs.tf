module "efs" {
  source          = "../..//app-infrastructure/efs"
  resource_prefix = var.resource_prefix
  vpc_id          = data.aws_vpc.nbs7.id
  vpc_cidrs       = data.aws_subnets.nbs7.ids
  kms_key_arn     = module.kms.kms_key_arn

  mount_targets = {
    for subnet in data.aws_subnets.nbs7.ids :
      data.aws_subnet.nbs7[subnet].availability_zone => {
      subnet_id = data.aws_subnet.nbs7[subnet].id
    }
  }
}
