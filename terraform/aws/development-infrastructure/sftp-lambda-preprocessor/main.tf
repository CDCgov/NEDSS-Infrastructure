provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "csv_to_hl7_topic" {
  name = "csv-to-hl7-topic"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_csv_to_hl7_role"
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

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_csv_to_hl7_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::${var.sftp_bucket_name}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${var.sftp_bucket_name}"
      },
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


#resource "aws_s3_bucket_notification" "sftp_trigger" {
#  bucket = var.sftp_bucket_name
#
#  lambda_function {
#    lambda_function_arn = aws_lambda_function.csv_to_hl7.arn
#    events              = ["s3:ObjectCreated:*"]
#    filter_suffix       = ".csv"
#  }

#  depends_on = [aws_lambda_permission.allow_s3_to_invoke_csv_to_hl7]
#}

resource "aws_s3_bucket_notification" "sftp_upload_notification" {
  bucket = var.sftp_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_to_hl7.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "usvi-test/usvi-test-testauto/incoming"
    filter_suffix       = ".csv"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.split_dat_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "usvi-test/usvi-test-testauto/incoming"
    filter_suffix       = ".dat"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.split_obr_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "usvi-test/usvi-test-testauto/incoming"
    filter_suffix       = ".hl7"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_to_invoke_csv_to_hl7,
    aws_lambda_permission.allow_s3_to_invoke_split_dat,
    aws_lambda_permission.allow_s3_to_invoke_split_obr
  ]
}

resource "aws_sns_topic" "csv_to_hl7_errors" {
  name = "csv-to-hl7-errors"
}

resource "aws_sns_topic" "split_dat_errors" {
  name = "split-dat-errors"
}

resource "aws_sns_topic" "split_obr_errors" {
  name = "split-obr-errors"
}

#resource "aws_sns_topic_subscription" "email_alert" {
#  topic_arn = aws_sns_topic.csv_to_hl7_errors.arn
#  protocol  = "email"
#  endpoint  = var.alert_email_address
#}

resource "aws_sns_topic_subscription" "csv_to_hl7_email" {
  topic_arn = aws_sns_topic.csv_to_hl7_errors.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_sns_topic_subscription" "split_dat_email" {
  topic_arn = aws_sns_topic.split_dat_errors.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_sns_topic_subscription" "split_obr_email" {
  topic_arn = aws_sns_topic.split_obr_errors.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_lambda_function" "csv_to_hl7" {
  function_name    = "csv-to-hl7"
  filename         = "build/lambda_csv_to_hl7.zip"
  source_code_hash = filebase64sha256("build/lambda_csv_to_hl7.zip")
  handler          = "lambda_split_csv.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      ERROR_TOPIC_ARN = aws_sns_topic.csv_to_hl7_errors.arn
      BUCKET          = var.sftp_bucket_name
    }
  }
}

resource "aws_lambda_function" "split_dat_lambda" {
  function_name    = "split_dat_lambda"
  filename         = "build/lambda_split_dat.zip"
  source_code_hash = filebase64sha256("build/lambda_split_dat.zip")
  handler          = "lambda_split_dat.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      ERROR_TOPIC_ARN = aws_sns_topic.split_dat_errors.arn
      BUCKET          = var.sftp_bucket_name
    }
  }
}

resource "aws_lambda_function" "split_obr_lambda" {
  function_name    = "split_obr_lambda"
  filename         = "build/lambda_split_obr.zip"
  source_code_hash = filebase64sha256("build/lambda_split_obr.zip")
  handler          = "lambda_split_obr.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      ERROR_TOPIC_ARN = aws_sns_topic.split_obr_errors.arn
      BUCKET          = var.sftp_bucket_name
    }
  }
}



resource "aws_lambda_permission" "allow_s3_to_invoke_csv_to_hl7" {
  statement_id  = "AllowExecutionFromS3Csv"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_to_hl7.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.sftp_bucket_name}"
}

resource "aws_lambda_permission" "allow_s3_to_invoke_split_dat" {
  statement_id  = "AllowExecutionFromS3Dat"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.split_dat_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.sftp_bucket_name}"
}

resource "aws_lambda_permission" "allow_s3_to_invoke_split_obr" {
  statement_id  = "AllowExecutionFromS3Obr"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.split_obr_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.sftp_bucket_name}"
}

