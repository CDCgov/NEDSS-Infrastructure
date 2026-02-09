data "aws_region" "current" {}

data "aws_vpc" "nbs7" {
  id = var.vpc_id
}

data "aws_subnets" "nbs7" {
  filter {
    name   = var.vpc_id
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_route53_zone" "root" {
  name = var.domain_name
}