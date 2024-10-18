data "aws_region" "current" {}

# ECS Service Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.resource_prefix}-ecs-execution-role"

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

  inline_policy {
      name   = "ecs_task_inline_policy_param_store"
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "ssm:GetParameters"
            ],
            Resource = "*"
          }
        ]
      })
    }
}

# ECS Task Role
# NOTE: inline_policy is required to allow SSM access in ECS container. This can be further restricted if required.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.resource_prefix}-ecs-task-role"

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

  inline_policy {
      name   = "ecs_task_inline_policy_ssm"
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
            ],
            Resource = "*"
          }
        ]
      })
    }    
}

# NBS 6 component ECS Cluster Creation
resource "aws_ecs_cluster" "cluster" {
  name = "${var.resource_prefix}-ecs-cluster"
  tags = var.tags
}


