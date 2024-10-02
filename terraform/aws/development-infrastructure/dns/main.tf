locals {
  private_zone_name = "private-${var.domain_name}"
}

# Conditional logic to handle when modern_vpc_id is null
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.10"

  zones = {
    (var.domain_name) = {
      comment = "${var.domain_name}"
    }

    (local.private_zone_name) = {
      comment = "${local.private_zone_name}"
      vpc = var.modern_vpc_id != null ? [
        {
          vpc_id = var.legacy_vpc_id
        },
        {
          vpc_id = var.modern_vpc_id
        }
      ] : [
        {
          vpc_id = var.legacy_vpc_id
        }
      ]
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "private_record" {
  zone_id = module.zones.route53_zone_zone_id["${local.private_zone_name}"]
  name    = var.nbs_db_dns
  type    = "CNAME"
  ttl     = 60
  records = [var.nbs_db_host_name]

  depends_on = [module.zones]
}

# add NS to public hosted zone in a different account
resource "aws_route53_record" "ns_record" {
  count    = var.hosted-zone-id != "" ? 1 : 0
  provider = aws.hosted-zone-account

  zone_id = var.hosted-zone-id
  name    = var.sub_domain_name
  type    = "NS"
  ttl     = 300
  records = [
    "${module.zones.route53_zone_name_servers["${var.domain_name}"][0]}.",
    "${module.zones.route53_zone_name_servers["${var.domain_name}"][1]}.",
    "${module.zones.route53_zone_name_servers["${var.domain_name}"][2]}.",
    "${module.zones.route53_zone_name_servers["${var.domain_name}"][3]}."
  ]
  depends_on = [module.zones]

}

