
# locals {

#   app_ingress = [{
#       from_port   = 7001
#       to_port     = 7001
#       protocol    = "tcp"
#       description = "wildfly web server"
#       cidr_blocks = "${var.ingress_vpc_cidr_blocks}"
#     }]
  
#   rdp_ingress = var.rdp_cidr_block != "" ? [{
#       from_port   = 3389
#       to_port     = 3389
#       protocol    = "tcp"
#       description = "RDP access from client VPN"
#       cidr_blocks = "${var.rdp_cidr_block}" 
#     }] : []

#   computed_ingress_with_cidr_blocks = concat(local.app_ingress, local.rdp_ingress...)
#   # computed_ingress_with_cidr_blocks = local.rdp_ingress == {} ? [tolist(local.app_ingress)] : [tolist(local.app_ingress, local.rdp_ingress)]
#   number_of_computed_ingress_with_cidr_blocks = local.rdp_ingress == {} ? 1 : 2
# }

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
  # computed_ingress_with_cidr_blocks = local.computed_ingress_with_cidr_blocks
  # number_of_computed_ingress_with_cidr_blocks = local.number_of_computed_ingress_with_cidr_blocks
}

# Additional ingress for cluster api access
resource "aws_vpc_security_group_ingress_rule" "app" {
  for_each = toset(var.nbs6_ingress_vpc_cidr_blocks)
  security_group_id = module.app_sg.security_group_id

  cidr_ipv4   = each.key
  from_port   = 7001
  ip_protocol = "tcp"
  to_port     = 7001
  description = "Wildfly web server"
}

# Additional ingress for cluster api access
resource "aws_vpc_security_group_ingress_rule" "rdp" {
  for_each = toset(var.nbs6_rdp_cidr_block)
  security_group_id = module.app_sg.security_group_id

  cidr_ipv4   = each.key
  from_port   = 3389
  ip_protocol = "tcp"
  to_port     = 3389
  description = "RDP access"
}

# Allow access on all ports for resources with this security group.
resource "aws_vpc_security_group_ingress_rule" "sas_rule" {
  for_each = toset(var.nbs6_rdp_cidr_block)
  security_group_id = module.app_sg.security_group_id

  referenced_security_group_id = module.app_sg.security_group_id
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
  description = "NBS-SAS communication"
}