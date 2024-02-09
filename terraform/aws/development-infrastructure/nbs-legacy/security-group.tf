
locals {
  app_ingress = {
      from_port   = 7001
      to_port     = 7001
      protocol    = "tcp"
      description = "wildfly web server"
      cidr_blocks = "${var.ingress_vpc_cidr_blocks}"
    }
  
  rdp_ingress = var.rdp_cidr_block != "" ? {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "RDP access from client VPN"
      cidr_blocks = "${var.rdp_cidr_block}" 
    } : {}

  computed_ingress_with_cidr_blocks = tolist([local.app_ingress, local.rdp_ingress])
  # computed_ingress_with_cidr_blocks = local.rdp_ingress == {} ? [tolist(local.app_ingress)] : [tolist(local.app_ingress, local.rdp_ingress)]
  number_of_computed_ingress_with_cidr_blocks = local.rdp_ingress == {} ? 1 : 2
}

# Security group for NBS application server
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name         = "${var.resource_prefix}-app-sg"
  description  = "Security group for NBS application server"
  # vpc_id       = var.legacy_vpc_id
  vpc_id       = var.vpc_id
  egress_rules = ["all-all"]

  # Open for ALB source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 7001
      to_port                  = 7001
      protocol                 = "tcp"
      description              = "Wildfly web server"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  # Open for RDP ingress and selected cidr blocks
  computed_ingress_with_cidr_blocks = local.computed_ingress_with_cidr_blocks
  number_of_computed_ingress_with_cidr_blocks = local.number_of_computed_ingress_with_cidr_blocks
}
