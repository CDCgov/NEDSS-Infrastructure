# Serial: 2024042601

module "kms" {
  source      = "../app-infrastructure/kms"
  aliases     = ["efs/${var.resource_prefix}"]
  description = "KMS key used for EFS: ${var.resource_prefix}"
}
