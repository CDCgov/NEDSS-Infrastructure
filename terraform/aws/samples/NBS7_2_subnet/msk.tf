# Serial: 2024010201

module "msk" {
  source              = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/msk?ref=v1.2.2-DEV"
  msk_subnet_ids      = [
    local.list_subnet_ids[0],
    local.list_subnet_ids[1]
  ]
  vpc_id              = data.aws_vpc.vpc_1.id
  msk_ebs_volume_size = var.msk_ebs_volume_size
  # now combining cidr blocks to make vpn cidr optional
  cidr_blocks = [data.aws_vpc.vpc_1.cidr_block] # can add this to list if needed: var.shared_vpc_cidr_block
  #cidr_blocks     = [var.modern-cidr, var.shared_vpc_cidr_block]
  resource_prefix = var.resource_prefix
  environment = var.msk_environment
}
