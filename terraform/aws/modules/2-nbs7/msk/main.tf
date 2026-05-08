locals {
  module_name          = "msk"
  module_serial_number = "2026-05-07_01" # Update with each commit? Date plus two digit increment.

  # The "Best practices for Standard brokers" page (https://docs.aws.amazon.com/msk/latest/developerguide/bestpractices.html) specifies the max number of partitions per broker, for each broker size (https://docs.aws.amazon.com/msk/latest/developerguide/broker-instance-sizes.html).
  # That page states if the number of partitions on any given broker "exceeds the maximum allowed value" then certain operations on the cluster will not be allowed - e.g. when
  # running a `terraform apply` command to step-up your MSK cluster to a new configuration revision, the command will fail with:
  #   "api error HighPartitionCountException: The number of partitions per broker is above the recommended limit. Add more brokers and rearrange the partitions per broker to be below the recommended limit, then retry the request"
  # Other options to resolve that error (i.e. getting the number of partitions on each broker below the limit) are to choose a larger broker size, or to delete unneeded topics (if there are enough such topics).
  # To get the number of partitions on each broker in your cluster: in the AWS Management Console go to CloudWatch, All metrics, search for "AWS/Kafka", click "Kafka > Broker ID, Cluster Name", and filter on your cluster name and on the PartitionCount metric.
  #  * That metric is what AWS uses to determine whether the limit is exceeded on any broker, and when you make a change to your cluster such as deleting topics it can take up to 10 minutes for that metric to be updated accordingly.
  # For production: typically at minimum use kafka.m5.large, and for high-throughput environments consider using kafka.m5.2xlarge or higher.
  broker_instance_type = var.environment == "development" ? "kafka.t3.small" : "kafka.m5.large"

  # Do not include additional brokers as part of Replication Factor (explained further below).
  base_number_of_brokers  = var.environment == "development" ? 2 : 3
  total_number_of_brokers = local.base_number_of_brokers + var.additional_brokers_to_create
}

resource "aws_cloudwatch_log_group" "test" {
  count = var.create_msk ? 1 : 0
  name  = "${var.resource_prefix}-msk-broker-logs"
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

# MSK Cluster Security Group
resource "aws_security_group" "msk_cluster_sg" {
  count       = var.create_msk ? 1 : 0
  name        = "${var.resource_prefix}-msk-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name          = "msk-cluster-sg"
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

resource "aws_security_group_rule" "msk_cluster_plaintext" {
  count       = var.create_msk ? 1 : 0
  description = "Allow world to communicate with the cluster"
  from_port   = 9092
  # allow connection from modern vpc and VPN
  cidr_blocks       = var.cidr_blocks # [var.modern-cidr, var.vpn-cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_cluster_sg[0].id
  to_port           = 9092
  type              = "ingress"
}

resource "aws_security_group_rule" "msk_cluster_tls" {
  count             = var.create_msk ? 1 : 0
  description       = "Allow world to communicate with the cluster"
  from_port         = 9094
  cidr_blocks       = var.cidr_blocks # [var.modern-cidr, var.vpn-cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_cluster_sg[0].id
  to_port           = 9094
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  count             = var.create_msk ? 1 : 0
  description       = "Allow cluster to communicate to vpc"
  from_port         = 1024
  cidr_blocks       = var.cidr_blocks # [var.modern-cidr, var.vpn-cidr]
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_cluster_sg[0].id
  to_port           = 65535
  type              = "egress"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
resource "aws_msk_cluster" "this" {
  count                  = var.create_msk ? 1 : 0
  cluster_name           = "${var.resource_prefix}-${var.environment}-msk-cluster"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = local.total_number_of_brokers

  configuration_info {
    arn      = aws_msk_configuration.msk_configuration_environment[0].arn
    revision = aws_msk_configuration.msk_configuration_environment[0].latest_revision
  }

  broker_node_group_info {
    instance_type = local.broker_instance_type

    client_subnets = var.msk_subnet_ids

    security_groups = [aws_security_group.msk_cluster_sg[0].id]
    storage_info {
      ebs_storage_info {
        volume_size = var.msk_ebs_volume_size
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
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
        log_group = aws_cloudwatch_log_group.test[0].name
      }
    }
  }

  tags = {
    Environment   = var.environment
    ModuleVersion = "${local.module_name}-${local.module_serial_number}"
  }
}

locals {
  # Reference info: https://docs.confluent.io/platform/current/installation/configuration/index.html
  #
  # Things to note about ensuring high availability of your Kafka cluster:
  #  * Partitions are for scalability and performance (they split a topic's data across multiple brokers), whereas replicas (i.e. a copy of a topic partition stored on a broker) are for availability and fault tolerance.
  #  * num.partitions is the number of partitions for each topic.
  #  * RF (Replication Factor) is the number of replicas for each topic. RF is generally set to at least 2, and set to 3 for production.
  #  * MinISR (min.insync.replicas) sets the minimum number of in-sync replicas (ISR) that must acknowledge a write for it to be considered successful.
  #    ** It's a best practice to set MinISR (min.insync.replicas) to at most RF - 1 in order to preserve high availability. A standard resilient configuration for a topic with RF=3 is to set MinISR=2.
  #    ** If you set MinISR >= RF then you'll receive a notification in AWS User Notifications stating your cluster does not have high availability and advising you to change your MSK cluster configuration so that MinISR is at most RF - 1.
  # Guidance for choosing values for configuration settings in the server.properties file:
  #  * For production, as noted on the "Best practices for Standard brokers" page mentioned above, set RF to 3. (There might be other changes needed to this Terraform module for it to be used by a production environment, such as possibly setting num.partitions=3 and auto.create.topics.enable=false.)
  #  * For non-production, if minimizing resource usage is more of a priority to you than simulating production behavior, then if 2 brokers is sufficient to support your number of partitions then set RF=2 (and MinISR=1). This can be sufficient to achieve high availability, so long as MinISR is at most RF - 1.
  #
  # More considerations for production environments:
  #  * https://repost.aws/knowledge-center/msk-avoid-disruption-during-patching
  #  * https://docs.aws.amazon.com/securityhub/latest/userguide/msk-controls.html

  min_ISR = local.base_number_of_brokers - 1

  # The unclean.leader.election.enable configuration setting should almost always be set to false, to prevent out-of-sync replicas from becoming leaders (which could cause silent data loss).
  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
default.replication.factor=${local.base_number_of_brokers}
min.insync.replicas=${local.min_ISR}
num.io.threads=8
num.network.threads=5
num.partitions=1
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=false
zookeeper.session.timeout.ms=18000
offsets.topic.replication.factor=${local.base_number_of_brokers}
transaction.state.log.replication.factor=${local.base_number_of_brokers}
PROPERTIES
}

# Reference info: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration
resource "aws_msk_configuration" "msk_configuration_environment" {
  count          = var.create_msk ? 1 : 0
  kafka_versions = ["2.8.1"]
  name           = "${var.resource_prefix}-${var.environment}-msk-cluster-config"

  server_properties = local.server_properties
}
