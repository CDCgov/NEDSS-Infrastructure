# Security group for NBS load balancer security group
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.resource_prefix}-alb-sg"
  description = "${var.resource_prefix} Security Group for ALB"
#   vpc_id      = var.legacy_vpc_id
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}


# Application load balancer for NBS application server
module "alb" {  
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.2"

  name = var.deploy_on_ecs ? "${var.resource_prefix}-alb-ecs" : "${var.resource_prefix}-alb-ec2"

  load_balancer_type = var.load_balancer_type
  internal = var.internal

  # Use `subnet_mapping` to select specific IP  
  subnet_mapping = var.subnet_mapping

  # Care here
#   vpc_id          = var.legacy_vpc_id
  vpc_id          = var.vpc_id
  subnets         = var.load_balancer_subnet_ids 
  security_groups = [module.alb_sg.security_group_id]


  target_groups = [
    {
      name_prefix      = "lgcy-"
      backend_protocol = "HTTP"
      backend_port     = 7001
      target_type      = var.deploy_on_ecs ? "ip" : "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/nbs/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }

      targets = var.deploy_on_ecs ? {} : {
        my_target = {
          target_id = module.app_server[0].id
          port      = 7001
        }
      } 
    }
  ]

  https_listeners = [
    {
      port     = 443
      protocol = "HTTPS"
      # Use terraform create certificate or a precreated certificate
      certificate_arn    = try(module.acm[0].acm_certificate_arn, var.certificate_arn)
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

resource "aws_route53_record" "alb_dns_record" {
  count = var.zone_id != "" && var.route53_url_name != "" ? 1 : 0
  zone_id = var.zone_id
  name    = var.route53_url_name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}