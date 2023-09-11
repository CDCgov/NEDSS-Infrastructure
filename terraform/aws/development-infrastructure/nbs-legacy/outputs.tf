output "nbs_db_address" {
  value = module.db.db_instance_address
}

output "nbs_app_alb" {
  value = module.alb.lb_dns_name
}