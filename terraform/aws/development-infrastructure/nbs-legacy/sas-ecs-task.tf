locals {
  container_port = 2323
}

# NBS6 SAS ECS Task Definition
resource "aws_ecs_task_definition" "sas_task" {
  count = var.deploy_sas ? 1 : 0
  family                   = "${var.resource_prefix}-sas-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn
  cpu                      = "${var.sas_ecs_cpu}"
  memory                   = "${var.sas_ecs_memory}"
  runtime_platform {
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {      
      name  = "${var.resource_prefix}-sas-task",
      image = "${var.sas_docker_image}",
      tags = var.tags,
      readonlyRootFilesystem = true,
      portMappings = [
        {
          containerPort = local.container_port,
          hostPort      = local.container_port
        }
      ],
      environment = [
        {
          name  = "db_host",
          value = "${var.nbs_db_dns}"
        },
        {
          name  = "rdb_user",
          value = "${var.rdb_user}"
        },
        {
          name  = "odse_user",
          value = "${var.odse_user}"
        },
        {
          name  = "db_trace_on",
          value = "${var.db_trace_on}"
        },
        {
          name  = "update_database",
          value = "${var.update_database}"
        },
        {
          name  = "PHCMartETL_cron_schedule",
          value = "${var.phcmartetl_cron_schedule}"
        },
        {
          name  = "MasterEtl_cron_schedule",
          value = "${var.masteretl_cron_schedule}"
        }
      ]
      secrets = [
        {
          name = "rdb_pass"
          valueFrom = "${aws_ssm_parameter.rdb_secret.arn}"
        },
        {
          name = "odse_pass"
          valueFrom = "${aws_ssm_parameter.odse_secret.arn}"
        }
      ]
        logConfiguration = {
            logDriver = "awslogs",
            options = {
            awslogs-group         = aws_cloudwatch_log_group.sas_log_group[0].name,
            awslogs-region        = data.aws_region.current.name,
            awslogs-stream-prefix = "ecs"
            }
        }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:2323 || exit 1"],
        interval    = 60,
        timeout     = 5,
        retries     = 5,
        startPeriod = 60
      }
    }
  ])
}

# NBS 6 app ECS Service Definition
# NOTE: enable_execute_command is required to exec in to ecs task
resource "aws_ecs_service" "sas_service" {
  count = var.deploy_sas ? 1 : 0
  name            = "${var.resource_prefix}-sas-ecs-service"
  cluster         = aws_ecs_cluster.cluster[0].id
  task_definition = aws_ecs_task_definition.sas_task[0].arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.ecs_subnets
    security_groups = ["${module.app_sg.security_group_id}"]
  }

  # load_balancer {
  #   target_group_arn = module.alb.target_group_arns[0]
  #   container_name   = "${var.resource_prefix}-sas-task"
  #   container_port   = local.container_port
  # }
  
  desired_count = 1
  enable_execute_command = true
  tags = var.tags  
}

# Secrets to inject into sas container
resource "aws_ssm_parameter" "odse_secret" {
  name  = "/${var.resource_prefix}-sas/odse_pass"
  type  = "SecureString"
  value = "${var.odse_pass}"
}

resource "aws_ssm_parameter" "rdb_secret" {
  name  = "/${var.resource_prefix}-sas/rdb_pass"
  type  = "SecureString"
  value = "${var.rdb_pass}"
}

# NBS 6 SAS component ECS CloudWatch Group
resource "aws_cloudwatch_log_group" "sas_log_group" {
  count = var.deploy_sas ? 1 : 0
  name = "/ecs/${var.resource_prefix}-sas-task"
}
