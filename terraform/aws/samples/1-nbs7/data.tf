data "aws_region" "current" {}

data "aws_vpc" "nbs7" {
  id = var.vpc_id
}

data "aws_subnets" "nbs7" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.nbs7.id]
  }
}

data "aws_subnet" "nbs7" {
  for_each = toset(data.aws_subnets.nbs7.ids)
  id       = each.value
}

data "aws_route53_zone" "root" {
  name = var.domain_name
}