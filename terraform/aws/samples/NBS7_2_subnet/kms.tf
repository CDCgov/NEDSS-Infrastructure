module "kms" {
  source      = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/kms?ref=v1.2.2-DEV"
  aliases     = ["efs/${var.resource_prefix}-key"]
  description = "KMS key used for EFS: ${var.resource_prefix}-efs"
}
