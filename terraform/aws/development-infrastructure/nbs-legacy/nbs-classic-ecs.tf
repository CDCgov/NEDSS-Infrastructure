# ECS Service Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  count = var.deploy_on_ecs ? 1 : 0
  name = "${var.legacy_resource_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  count = var.deploy_on_ecs ? 1 : 0
  name = "${var.legacy_resource_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# NBS 6 ECS CloudWatch Group
resource "aws_cloudwatch_log_group" "log_group" {
  count = var.deploy_on_ecs ? 1 : 0
  name = "/ecs/${var.legacy_resource_prefix}-task"
}

# NBS 6 ECS Cluster Creation
resource "aws_ecs_cluster" "cluster" {
  count = var.deploy_on_ecs ? 1 : 0
  name = "${var.legacy_resource_prefix}-app-ecs-cluster"
  tags = var.tags
}

# NBS 6 ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  count = var.deploy_on_ecs ? 1 : 0
  family                   = "${var.legacy_resource_prefix}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn
  cpu                      = "2048"  # 2 vCPU
  memory                   = "8192" # 8GB
  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_FULL"
  }

  container_definitions = jsonencode([
    {
      name  = "${var.legacy_resource_prefix}-task",
      image = "${var.docker_image}",
      tags = var.tags,
      portMappings = [
        {
          containerPort = 7001,
          hostPort      = 7001
        }
      ],
      environment = [
        {
          name  = "RDS_ENDPOINT",
          value = "${var.nbs_db_dns}"
        }
      ]
        logConfiguration = {
            logDriver = "awslogs",
            options = {
            awslogs-group         = aws_cloudwatch_log_group.log_group[0].name,
            awslogs-region        = "us-east-1",
            awslogs-stream-prefix = "ecs"
            }
        }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:7001/nbs/login || exit 1"],
        interval    = 60,
        timeout     = 5,
        retries     = 5,
        startPeriod = 60
      }
    }
  ])
}


# NBS 6 ECS Service Definition
resource "aws_ecs_service" "service" {
  count = var.deploy_on_ecs ? 1 : 0
  name            = "${var.legacy_resource_prefix}-app-ecs-service"
  cluster         = aws_ecs_cluster.cluster[0].id
  task_definition = aws_ecs_task_definition.task[0].arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [var.private_subnet_ids[0]]
    security_groups = ["${module.app_sg.security_group_id}"]
  }

  load_balancer {
    target_group_arn = module.alb_ecs[0].target_group_arns[0]
    container_name   = "${var.legacy_resource_prefix}-task"
    container_port   = 7001
  }
  
  desired_count = 1
  enable_execute_command = true
  tags = var.tags
  depends_on = [module.db]
}



# Application load balancer for ECS NBS application server
module "alb_ecs" {
  count = var.deploy_on_ecs ? 1 : 0
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.2"

  name = "${var.legacy_resource_prefix}-alb-ecs"

  load_balancer_type = "application"

  vpc_id          = var.legacy_vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [module.alb_sg.security_group_id]


  target_groups = [
    {
      name_prefix      = "lgcy-"
      backend_protocol = "HTTP"
      backend_port     = 7001
      target_type      = "ip"

      health_check = {
        enabled             = true
        interval            = 60
        path                = "/nbs/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 5
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
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

resource "aws_route53_record" "alb_ecs_dns_record" {
  count = var.deploy_on_ecs ? 1 : 0
  zone_id = var.zone_id
  name    = var.route53_url_name
  type    = "A"

  alias {
    name                   = module.alb_ecs[0].lb_dns_name
    zone_id                = module.alb_ecs[0].lb_zone_id
    evaluate_target_health = true
  }
}