module "s3_datacompare" {
  count                                  = var.create_datacompare_resources ? 1 : 0
  source                                 = "../../app-infrastructure/s3-bucket"
  tags                                   = var.tags
  bucket_prefix                          = "${var.resource_prefix}-"
  enable_default_bucket_lifecycle_policy = "Enabled"
}

module "s3_otel_logs" {
  count                                  = var.create_otel_collector_resources ? 1 : 0
  source                                 = "../../app-infrastructure/s3-bucket"
  tags                                   = var.tags
  bucket_prefix                          = "${var.resource_prefix}-otel-logs-"
  enable_default_bucket_lifecycle_policy = "Enabled"
}