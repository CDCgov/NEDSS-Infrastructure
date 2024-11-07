# Serial: 2024110101

module "vpc-endpoints" {

  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/vpc-endpoints-nbs?ref=v1.2.20"

  #source                         = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/vpc-endpoints-nbs"

  # SAMPLES
  # source             = "../app-infrastructure/vpc-endpoints-nbs"

  create_prometheus_vpc_endpoint = var.create_prometheus_vpc_endpoint
  create_grafana_vpc_endpoint    = var.create_grafana_vpc_endpoint
  tags                           = var.tags
  private_subnet_ids             = module.modernization-vpc.private_subnets
  vpc_id                         = module.modernization-vpc.vpc_id
  vpc_cidr_block                 = module.modernization-vpc.vpc_cidr_block
  resource_prefix                = var.resource_prefix

}
