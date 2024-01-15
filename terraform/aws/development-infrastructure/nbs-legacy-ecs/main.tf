# Prerequisites
# 1. Create key-pair in account if desired (leaving blank is untested)
# 2. Used domain is assumed to exist

#locals on whether to create CSM
locals {
  #If create_cert == true set value to 1 and create CSM, otherwise do not create
  cert_count = var.create_cert ? 1 : 0
}

# get legacy VPC data
data "aws_vpc" "legacy_vpc" {
  id = var.legacy_vpc_id
}

# get modernized VPC data
data "aws_vpc" "modern_vpc" {
  id = var.modern_vpc_id
}

# ECS Service Execution Role
resource "aws_iam_role" "ecs_execution_role" {
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
  name = "/ecs/${var.legacy_resource_prefix}-task"
}

# NBS 6 ECS Cluster Creation
resource "aws_ecs_cluster" "cluster" {
  name = "${var.legacy_resource_prefix}-app-ecs-cluster"
  tags = var.tags
}

# NBS 6 ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.legacy_resource_prefix}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = "2048"  # 2 vCPU
  memory                   = "8192" # 8GB
  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_FULL"
  }

  container_definitions = jsonencode([
    {
      name  = "${var.legacy_resource_prefix}-task",
      image = "${var.legacy_docker_image}",
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
            awslogs-group         = aws_cloudwatch_log_group.log_group.name,
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
  name            = "${var.legacy_resource_prefix}-app-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [var.private_subnet_ids[0]]
    security_groups = ["${module.app_sg.security_group_id}"]
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "${var.legacy_resource_prefix}-task"
    container_port   = 7001
  }
  
  desired_count = 1
  enable_execute_command = true
  tags = var.tags
  depends_on = [module.db]
}


# Security group for NBS application server
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name         = "${var.legacy_resource_prefix}-app-sg"
  description  = "Security group for NBS application server"
  vpc_id       = var.legacy_vpc_id
  egress_rules = ["all-all"]

  # Open for ALB source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 7001
      to_port                  = 7001
      protocol                 = "tcp"
      description              = "ECS Wildfly Web Server"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
}

# Security group for NBS load balancer security group
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.legacy_resource_prefix}-alb-sg"
  description = "${var.legacy_resource_prefix} Security Group for ALB"
  vpc_id      = var.legacy_vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}


# Application load balancer for NBS application server
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.2"

  name = "${var.legacy_resource_prefix}-alb"

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

resource "aws_route53_record" "alb_dns_record" {
  zone_id = var.zone_id
  name    = var.route53_url_name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

# Security group for NBS backend RDS database server
module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name         = "${var.legacy_resource_prefix}-rds-sg"
  description  = "Security group for RDS instance"
  vpc_id       = var.legacy_vpc_id
  egress_rules = ["all-all"]

  # Open for application server source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 1433
      to_port                  = 1433
      protocol                 = "tcp"
      description              = "MSSQL RDS instance access from EC2"
      source_security_group_id = module.app_sg.security_group_id
    }
  ]

  # Open for shared services and legacy VPC cidr block
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL RDS instance access from within VPCs"
      cidr_blocks = "${var.shared_vpc_cidr_block},${data.aws_vpc.legacy_vpc.cidr_block},${data.aws_vpc.modern_vpc.cidr_block}"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1

}

# NBS backend RDS database instance
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.2"

  identifier = "${var.legacy_resource_prefix}-rds-mssql"

  engine               = "sqlserver-se"
  engine_version       = "15.00"
  family               = "sqlserver-se-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group
  instance_class       = var.db_instance_type

  //allocated_storage     = 20
  //max_allocated_storage = 100

  # Encryption at rest is not available for DB instances running SQL Server Express Edition
  storage_encrypted = true

  //username = "admin"
  //port     = 1433


  multi_az = false
  # db_subnet_group_name   = "legacy-db-subnet-group"
  # create DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.private_subnet_ids
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled = false
  create_monitoring_role       = false
  /*
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
*/
  options                   = []
  create_db_parameter_group = false
  license_model             = "license-included"
  character_set_name        = "SQL_Latin1_General_CP1_CI_AS"
  snapshot_identifier       = var.db_snapshot_identifier
  apply_immediately = var.apply_immediately
}

# Create certificate (this should be an optional resource with ability to provide arn if existing)
# Needs CNAME record in route53
module "acm" {
  count   = local.cert_count
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

