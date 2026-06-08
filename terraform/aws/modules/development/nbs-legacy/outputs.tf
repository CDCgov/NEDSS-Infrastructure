output "nbs_app_alb" {
  value = module.alb.lb_dns_name
}

# output "nbs_ecs_app_alb" {
#   value = var.deploy_on_ecs ? module.alb_ecs[0].lb_dns_name : "Not Created"
# }

output "security_group_id" {
  value = module.app_sg.security_group_id
}