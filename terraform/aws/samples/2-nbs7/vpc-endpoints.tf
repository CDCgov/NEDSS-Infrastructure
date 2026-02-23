module "vpc-endpoints" {
  source = "../../app-infrastructure/vpc-endpoints-nbs"

  create_prometheus_vpc_endpoint = var.create_prometheus_vpc_endpoint
  create_grafana_vpc_endpoint    = var.create_grafana_vpc_endpoint
  tags                           = var.tags
  private_subnet_ids             = data.aws_subnets.nbs7.ids
  vpc_id                         = data.aws_vpc.nbs7.id
  vpc_cidr_block                 = data.aws_vpc.nbs7.cidr_block
  resource_prefix                = var.resource_prefix
}
