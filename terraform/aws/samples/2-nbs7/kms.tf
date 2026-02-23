module "kms" {
  source      = "../../app-infrastructure/kms"
  aliases     = ["efs/${var.resource_prefix}-key"]
  description = "KMS key used for EFS: ${var.resource_prefix}-efs"
}
