module "acm" {
  count   = var.create_cert ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = var.zone_id

  # subject_alternative_names = [
  #   "*.my-domain.com",
  #   "app.sub.my-domain.com",
  # ]

  wait_for_validation = true
  validation_timeout  = "15m"
  tags                = var.tags
}