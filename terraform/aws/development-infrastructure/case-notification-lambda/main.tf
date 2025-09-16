locals {
  lambda_function_name = "${var.resource_prefix}-case-notification-lambda"
}

# Secrets Manager Secret for SFTP access
resource "aws_secretsmanager_secret" "case_notification_sftp" {
  name = "${var.resource_prefix}-case-notification-sftp"
  kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null 
}

resource "aws_secretsmanager_secret_version" "case_notification_sftp" {
  secret_id     = aws_secretsmanager_secret.case_notification_sftp.id

  secret_string = jsonencode({
    sftp_hostname = "${var.sftp_hostname}"
    sftp_username = "${var.sftp_username}"
    sftp_password  = "${var.sftp_password}"
  })
}

# Secrets Manager Secret for DB access
resource "aws_secretsmanager_secret" "case_notification_db" {
  name = "${var.resource_prefix}-case-notification-db"
  kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null
}

resource "aws_secretsmanager_secret_version" "case_notification_db" {
  secret_id     = aws_secretsmanager_secret.case_notification_db.id

  secret_string = jsonencode({
    server_name = "${var.rds_server_name}"
    username = "${var.database_user_name}"
    password  = "${var.database_user_password}"
  })
}

# Lambda IAM execution role
resource "aws_iam_role" "lambda_exec" {
  name = "${var.resource_prefix}-lambda-case-notfication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  }) 
}

# lambda IAM resource policy
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.resource_prefix}-lambda-case-notfication-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances"          
        ],
        Resource = "arn:aws:rds:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_server_name}"
      },
      {
        Effect = "Allow",
        Action = [          
          "lambda:InvokeFunction"          
        ],
        Resource = "arn:aws:lambda:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_function_name}"
      },
      {
        Effect = "Allow",
        Action = [          
          "secretsmanager:GetSecretValue"
        ],
        Resource = ["${aws_secretsmanager_secret.case_notification_sftp.arn}", "${aws_secretsmanager_secret.case_notification_db.arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda__managed_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# Package the Lambda function code
data "archive_file" "this" {
  type        = "zip"
  source_file = "${path.module}/lambda/case_notification.py"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda security group
resource "aws_security_group" "this" {
  name        = "no_inbound_traffic"
  description = "Allow only outbound traffic"
  vpc_id      = var.vpc_id

  tags = var.tags
  # Applies tags on creation but ignores changes after the facts
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Lambda function
resource "aws_lambda_function" "this" {
  tags = var.tags
  filename         = data.archive_file.this.output_path
  function_name    = local.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "case_notification.lambda_handler"
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout       = var.timeout
  runtime = var.python_runtime
  
  # Add local lambda layer
  layers = [ aws_lambda_layer_version.case-notification-layer.id ]

  environment {
    variables = {
      DRY_RUN = "${var.lambda_env_dry_run}"      
      MAX_BATCH_SIZE = "${var.lambda_env_max_batch_size}"
      REPORTED_SERVICE_TYPES = "${var.lambda_env_reported_service_types}"    
      SFTP_PUT_FILEPATH = "${var.lambda_env_sftp_put_filepath}"
      LOG_LEVEL   = "${var.lambda_env_log_level}"
      SECRET_MANAGER_SFTP_SECRET = "${aws_secretsmanager_secret.case_notification_sftp.name}"
      SECRET_MANAGER_DB_SECRET = "${aws_secretsmanager_secret.case_notification_db.name}"
    }
  }

  # Config to attach lambda to VPC
  vpc_config {
    subnet_ids                  = var.subnet_ids
    security_group_ids          = [aws_security_group.this.id]     
  }

  # Increase /tmp storage to 5GB
  ephemeral_storage {
    size = var.tmp_storage
  }

  # Applies tags on creation but ignores changes after the facts
  lifecycle {
    ignore_changes = [tags]
  }
}

# Lambda layer
resource "aws_lambda_layer_version" "case-notification-layer" {
  filename   = "${path.module}/layers/case-notification-layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/layers/case-notification-layer.zip") # automated update if .zip changes
  layer_name = "${var.resource_prefix}-case-notification-layer"
  compatible_runtimes = [var.python_runtime]
  description = "Lambda layer with pyobdc library including odbc driver, and paramiko library"
}

# lambda async config
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.this.function_name

  # max age of event in case of slowness
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  # max retry attempts, since db is involved
  maximum_retry_attempts       = var.maximum_retry_attempts
  
}
