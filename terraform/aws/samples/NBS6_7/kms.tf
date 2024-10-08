# Serial: 2024081301

module "kms" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/kms?ref=v1.2.14"

  #source      = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/kms"

  # SAMPLES
  #source      = "../app-infrastructure/kms"

  aliases     = ["efs/${var.resource_prefix}"]
  description = "KMS key used for EFS: ${var.resource_prefix}"
}
