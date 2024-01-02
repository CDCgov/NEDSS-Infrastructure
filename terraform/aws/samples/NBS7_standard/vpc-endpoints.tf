module "vpc-endpoints" {
  source             = "../app-infrastructure/vpc-endpoints-nbs"
  resource_prefix    = var.resource_prefix
  tags               = var.tags
  region             = data.aws_region.current.name
  vpc_id             = module.modernization-vpc.vpc_id
  vpc_cidr_block     = module.modernization-vpc.vpc_cidr_block
  private_subnet_ids = module.modernization-vpc.private_subnets
}
