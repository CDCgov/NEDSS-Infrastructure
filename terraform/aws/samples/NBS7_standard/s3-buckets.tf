module "fluentbit-bucket" {
    source = "../app-infrastructure/s3-bucket"
    bucket_prefix = var.fluentbit_bucket_prefix
    tags = var.tags
}