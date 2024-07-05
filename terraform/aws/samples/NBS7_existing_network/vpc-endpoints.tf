# Serial: 2024042601

module "vpc-endpoints" {
  source             = "../app-infrastructure/vpc-endpoints-nbs"

  create_prometheus_vpc_endpoint = var.create_prometheus_vpc_endpoint
  create_grafana_vpc_endpoint    = var.create_grafana_vpc_endpoint
  tags                           = var.tags
  private_subnet_ids             = module.modernization-vpc.private_subnets
  #vpc_id                         = module.modernization-vpc.vpc_id
  vpc_id                     = data.aws_vpc.vpc_1.id
  vpc_cidr_block                 = module.modernization-vpc.vpc_cidr_block
  #subnets                    = var.modernization-vpc-private-subnets
  #vpc_id                      = var.modernization-vpc-id
  #vpc_cidrs       = var.modernization-vpc-private-subnets-cidr-blocks
  resource_prefix                = var.resource_prefix
}
