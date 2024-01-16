output "nbs_db_address" {
  value = module.db.db_instance_address
}

output "nbs_app_alb" {
  value = var.deploy_on_ecs ? "Not Created" : module.alb[0].lb_dns_name
}

output "nbs_ecs_app_alb" {
  value = var.deploy_on_ecs ? module.alb_ecs[0].lb_dns_name : "Not Created"
}