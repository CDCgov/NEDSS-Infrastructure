locals {
  efs_name = var.name != "" ? var.name : "${var.resource_prefix}-efs"
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "2.0.0"

  name        = local.efs_name
  encrypted   = true
  kms_key_arn = var.kms_key_arn

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid    = "AllowViaMountTarget"
      effect = "Allow"
      actions = [
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount",
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      conditions = [
        {
          test     = "Bool"
          variable = "elasticfilesystem:AccessedViaMountTarget"
          values   = ["true"]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets              = var.mount_targets
  security_group_description = "EFS Security Group for ${var.resource_prefix}-efs"
  security_group_vpc_id      = var.vpc_id

  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC subnets"
      cidr_blocks = var.vpc_cidrs
    }
  }
}
