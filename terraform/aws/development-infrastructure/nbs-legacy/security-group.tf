
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

  computed_ingress_with_cidr_blocks = local.rdp_ingress == {} ? [local.app_ingress] : [local.app_ingress, local.rdp_ingress]
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

# Add in-line IAM role for EC2 access to shared services bucket
resource "aws_iam_role_policy" "shared_s3_access" {
  count = var.deploy_on_ecs ? 0 : 1
  name = "cross_account_s3_access_policy"
  role = module.app_server[0].iam_role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = "${var.kms_arn_shared_services_bucket}"
      },
    ]
  })

  depends_on = [module.app_server]
}