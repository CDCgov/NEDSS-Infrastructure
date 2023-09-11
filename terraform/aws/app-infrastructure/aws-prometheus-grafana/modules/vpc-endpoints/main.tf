resource "aws_security_group" "prometheus_vpc_endpoint_sg" {
  name_prefix = var.prometheus_sg_name
  vpc_id              = var.vpc_id 
  tags = merge(tomap({"Name"=var.prometheus_sg_name}),var.tags)
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
  tags = merge(tomap({"Name"=var.prometheus_endpoint}),var.tags)
  vpc_id              = var.vpc_id 
  service_name        = "com.amazonaws.${var.region}.aps"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  
  security_group_ids = [
    aws_security_group.prometheus_vpc_endpoint_sg.id 
  ]
  
  subnet_ids = var.private_subnet_ids 
}


resource "aws_security_group" "grafana_vpc_endpoint_sg" {
  name_prefix = var.grafana_sg_name
  vpc_id              = var.vpc_id 
  tags = merge(tomap({"Name"=var.grafana_sg_name}),var.tags)
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
  vpc_id              = var.vpc_id 
  service_name        = "com.amazonaws.${var.region}.grafana"
  vpc_endpoint_type   = "Interface"
  tags = merge(tomap({"Name"=var.grafana_endpoint}),var.tags)
  private_dns_enabled = true
  
  security_group_ids = [
    aws_security_group.grafana_vpc_endpoint_sg.id 
  ]
  
  subnet_ids = var.private_subnet_ids 
}