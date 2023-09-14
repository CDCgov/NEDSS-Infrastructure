output "zone_id" {
  value = module.zones.route53_zone_zone_id
}

output "registered_domain_name" {
  value = var.domain_name
}

output "nbs_db_dns" {
  value = "${var.nbs_db_dns}.private-${var.domain_name}"
}
