# Serial: 2024121601

module "kms" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/kms?ref=v1.2.22"

  #source      = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/kms"

  # SAMPLES
  #source      = "../app-infrastructure/kms"

  aliases     = ["efs/${var.resource_prefix}"]
  description = "KMS key used for EFS: ${var.resource_prefix}"
}
