module "vpc-endpoints" {
  source = "../../modules/2-nbs7/vpc-endpoints-nbs"

  create_prometheus_vpc_endpoint = var.create_prometheus_vpc_endpoint
  create_grafana_vpc_endpoint    = var.create_grafana_vpc_endpoint
  tags                           = var.tags
  private_subnet_ids             = var.endpoint_private_subnet_ids == null ? data.aws_subnets.nbs7.ids : var.endpoint_private_subnet_ids
  vpc_id                         = data.aws_vpc.nbs7.id
  vpc_cidr_block                 = var.endpoint_vpc_cidr_block == null ? data.aws_vpc.nbs7.cidr_block : var.endpoint_vpc_cidr_block
  resource_prefix                = var.resource_prefix
}
