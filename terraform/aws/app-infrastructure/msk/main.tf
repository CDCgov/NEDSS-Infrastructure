locals {
  module_name = "msk"
  module_serial_number = "2023071301" # update with each commit?  Date plus two digit increment
  instance_type  = var.environment == "development" ? "kafka.t3.small" : "kafka.m5.large"
  instance_count = var.environment == "development" ? 2 : 3
}

# Create an IAM role for MSK
resource "aws_iam_role" "msk" {
  count = var.create_msk ? 1 : 0

  name = "${var.resource_prefix}-${var.environment}-msk-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kafka.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

# Create an IAM policy for MSK
resource "aws_iam_policy" "msk" {
  count = var.create_msk ? 1 : 0
  name   = "${var.resource_prefix}-${var.environment}-msk-policy"
  policy = jsonencode({
    Version: "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

# Attach the IAM policy to the MSK role
resource "aws_iam_role_policy_attachment" "msk" {
  count = var.create_msk ? 1 : 0
  policy_arn = aws_iam_policy.msk.arn
  role       = aws_iam_role.msk.name
}

resource "aws_cloudwatch_log_group" "test" {
  count = var.create_msk ? 1 : 0
  name = "${var.resource_prefix}-msk-broker-logs"
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

# MSK Cluster Security Group
resource "aws_security_group" "msk_cluster_sg" {
  count = var.create_msk ? 1 : 0
  name        = "${var.resource_prefix}-msk-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "msk-cluster-sg"
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

resource "aws_security_group_rule" "msk_cluster_plaintext" {
  count = var.create_msk ? 1 : 0
  description              = "Allow world to communicate with the cluster"
  from_port                = 9092
  # allow connection from modern vpc and VPN
  cidr_blocks               = [var.modern-cidr, var.vpn-cidr]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk_cluster_sg.id
  to_port                  = 9092
  type                     = "ingress"
}

resource "aws_security_group_rule" "msk_cluster_tls" {
  count = var.create_msk ? 1 : 0
  description              = "Allow world to communicate with the cluster"
  from_port                = 9094
  cidr_blocks               = [var.modern-cidr, var.vpn-cidr]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk_cluster_sg.id
  to_port                  = 9094
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  count = var.create_msk ? 1 : 0
  description              = "Allow cluster to communicate to vpc"
  from_port                = 1024
  cidr_blocks               = [var.modern-cidr, var.vpn-cidr]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk_cluster_sg.id
  to_port                  = 65535
  type                     = "egress"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
resource "aws_msk_cluster" "this" {
  count = var.create_msk ? 1 : 0
  cluster_name  = "${var.resource_prefix}-${var.environment}-msk-cluster"
  kafka_version = "2.8.1"
  number_of_broker_nodes = local.instance_count
  #iam_instance_profile = aws_iam_role.msk.arn

  configuration_info {
    arn = aws_msk_configuration.msk_configuration_environment.arn
    revision = 1 
  }

  broker_node_group_info {
    instance_type   = local.instance_type
    client_subnets  = var.msk_subnet_ids
    #security_groups = var.msk_security_groups
    security_groups = [aws_security_group.msk_cluster_sg.id]
    storage_info {
      ebs_storage_info {
        volume_size = var.msk_ebs_volume_size
      }
    }
  }

  encryption_info {
        encryption_in_transit {
            client_broker = "TLS_PLAINTEXT"
            in_cluster = true
        }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
    }
  }


  tags = {
    Environment = var.environment
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

resource "aws_msk_configuration" "msk_configuration_environment" {
  count = var.create_msk ? 1 : 0
  kafka_versions = ["2.8.1"]
  name           = "${var.resource_prefix}-${var.environment}-msk-cluster-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
default.replication.factor=2
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=1
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=true
zookeeper.session.timeout.ms=18000
PROPERTIES
}





