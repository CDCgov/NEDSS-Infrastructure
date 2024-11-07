# Serial: 2024110101

module "fluentbit-bucket" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/s3-bucket?ref=v1.2.20"
  # source  = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/s3-bucket"
  # SAMPLES
  # source  = "../app-infrastructure/s3-bucket"

  #bucket_prefix = var.fluentbit_bucket_prefix
  #bucket_prefix = var.resource_prefix
  bucket_prefix = "${var.resource_prefix}-fluentbit-logs-"
  tags          = var.tags
}

