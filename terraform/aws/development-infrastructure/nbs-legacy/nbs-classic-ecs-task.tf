# NBS 6 app ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  count = var.deploy_on_ecs ? 1 : 0
  family                   = "${var.resource_prefix}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = "${var.ecs_cpu}"
  memory                   = "${var.ecs_memory}"
  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_FULL"
  }

  container_definitions = jsonencode([
    {      
      name  = "${var.resource_prefix}-task",
      image = "${var.docker_image}",
      tags = var.tags,
      readonlyRootFilesystem = false,
      containerPortRange = 1
      portMappings = [
        {
          containerPort = 7001,
          hostPort      = 7001         
        },
        {
            containerPortRange = "7002-65535",
            protocol = "tcp"
        }
      ],
      environment = [
        {
          name  = "DATABASE_ENDPOINT",
          value = "${var.nbs_db_dns}"
        },
        {
          name  = "GITHUB_RELEASE_TAG",
          value = "${var.nbs_github_release_tag}"
        }
      ]
        logConfiguration = {
            logDriver = "awslogs",
            options = {
            awslogs-group         = aws_cloudwatch_log_group.log_group[0].name,
            awslogs-region        = data.aws_region.current.name,
            awslogs-stream-prefix = "ecs"
            }
        }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:7001/nbs/login || exit 1"],
        interval    = 60,
        timeout     = 5,
        retries     = 5,        
        startPeriod = 300
      }
    }
  ])
}


# NBS 6 app ECS Service Definition
# NOTE: enable_execute_command is required to exec in to ecs task
resource "aws_ecs_service" "service" {
  count = var.deploy_on_ecs ? 1 : 0
  name            = "${var.resource_prefix}-app-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task[0].arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.ecs_subnets
    security_groups = ["${module.app_sg.security_group_id}"]
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "${var.resource_prefix}-task"
    container_port   = 7001
  }
  
  desired_count = 1
  enable_execute_command = true
  tags = var.tags  
}

# NBS 6 component ECS CloudWatch Group
resource "aws_cloudwatch_log_group" "log_group" {
  count = var.deploy_on_ecs ? 1 : 0
  name = "/ecs/${var.resource_prefix}-task"
}