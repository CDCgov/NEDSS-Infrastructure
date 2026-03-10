module "kms" {
  source      = ".../.../modules/2-nbs7/kms"
  aliases     = ["efs/${var.resource_prefix}-key"]
  description = "KMS key used for EFS: ${var.resource_prefix}-efs"
}
