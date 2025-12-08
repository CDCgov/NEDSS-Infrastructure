resource "aws_security_group" "grafana_vpc_endpoint_sg" {
  count       = var.create_grafana_vpc_endpoint ? 1 : 0
  name_prefix = local.grafana_sg_name
  vpc_id      = var.vpc_id
  tags        = merge(tomap({ "Name" = local.grafana_sg_name }), var.tags)
  ingress {
    description = "VPC traffic"
    from_port   = 3000
    to_port     = 3000
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

resource "aws_vpc_endpoint" "grafana_vpc_endpoint" {
  count               = var.create_grafana_vpc_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.grafana"
  vpc_endpoint_type   = "Interface"
  tags                = merge(tomap({ "Name" = local.grafana_endpoint }), var.tags)
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.grafana_vpc_endpoint_sg[0].id
  ]

  subnet_ids = var.private_subnet_ids
}
