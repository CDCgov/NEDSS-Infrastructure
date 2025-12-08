resource "aws_security_group" "prometheus_vpc_endpoint_sg" {
  count       = var.create_prometheus_vpc_endpoint ? 1 : 0
  name_prefix = local.prometheus_sg_name
  vpc_id      = var.vpc_id
  tags        = merge(tomap({ "Name" = local.prometheus_sg_name }), var.tags)
  ingress {
    description = "VPC traffic"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  ingress {
    description = "VPC traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    description = "VPC traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "aws_vpc_endpoint" "prometheus_endpoint" {
  count               = var.create_prometheus_vpc_endpoint ? 1 : 0
  tags                = merge(tomap({ "Name" = local.prometheus_endpoint }), var.tags)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.aps"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.prometheus_vpc_endpoint_sg[0].id
  ]

  subnet_ids = var.private_subnet_ids
}
