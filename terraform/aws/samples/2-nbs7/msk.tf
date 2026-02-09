module "msk" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/msk?ref=v1.2.2-DEV"
  msk_subnet_ids = var.msk_environment == "production" ? [data.aws_subnets.nbs7.ids[0], data.aws_subnets.nbs7.ids[1], data.aws_subnets.nbs7.ids[2]] : [data.aws_subnets.nbs7.ids[0], data.aws_subnets.nbs7.ids[1]]
  vpc_id              = data.aws_vpc.nbs7.id
  msk_ebs_volume_size = var.msk_ebs_volume_size
  cidr_blocks = [data.aws_vpc.nbs7.cidr_block] # can add this to list if needed: var.shared_vpc_cidr_block  
  resource_prefix = var.resource_prefix
  environment     = var.msk_environment
}
