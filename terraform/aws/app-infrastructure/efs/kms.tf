module "kms" {
  source      = "../kms"
  aliases     = ["efs/${var.name}"]
  description = "KMS key used for EFS: ${var.name}"
}
