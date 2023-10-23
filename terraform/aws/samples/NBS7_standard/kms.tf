module "kms" {
  source      = "../app-infrastructure/kms"
  aliases     = ["efs/${var.modern-name}"]
  description = "KMS key used for EFS: ${var.modern-name}"
}
