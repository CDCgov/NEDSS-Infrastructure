module "fluentbit-bucket" {
  source        = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/s3-bucket?ref=v1.1.9-DEV"
  bucket_prefix = var.fluentbit_bucket_prefix
  tags          = var.tags
}
