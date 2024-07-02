# Serial: 2024010201

module "msk" {
  source              = "../app-infrastructure/msk"
  msk_subnet_ids      = module.modernization-vpc.private_subnets
  vpc_id              = module.modernization-vpc.vpc_id
  #subnets                    = var.modernization-vpc-private-subnets
  #vpc_id                      = var.modernization-vpc-id
  #vpc_cidrs       = var.modernization-vpc-private-subnets-cidr-blocks
  msk_ebs_volume_size = var.msk_ebs_volume_size
  # now combining cidr blocks to make vpn cidr optional
  cidr_blocks = [var.modern-cidr] # can add this to list if needed: var.shared_vpc_cidr_block
  #cidr_blocks     = [var.modern-cidr, var.shared_vpc_cidr_block]
  resource_prefix = var.resource_prefix
}
