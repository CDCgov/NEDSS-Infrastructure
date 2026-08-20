# Terraform AWS Module: development/case-notification-lambda

## Description

This module deploys and configures NBS 7 development resources for case notification Lambda functions

## Creating lambda layer for pyodbc and paramiko

### Requirements

- Linux environment or Docker environment such as Docker Desktop
- Ability to download remote packages/images from microsoft and public.ecr.aws/lambda/python

### Steps

Run the following steps

1. Within your command line starting at the case-notification-lambda directory

   ```
   cd ./docker
   docker build -t lambda-layer-msodbcsql18 .
   ```

2. Copy from container to the layers directory within case-notification-lambda module for deployment
   - cd ../
   - docker run --rm -v ${PWD}:/out --entrypoint cp lambda-layer-msodbcsql18 /layer.zip /out/layers/case-notification-lambda.zip
   ```
   docker cp <container_name_or_id>:/tmp/case-notification-layer.zip <path_on_local_machine_to_module>/layers
   ```
   **NOTE: folder structure when uploading to lambda layers**
   ```
       /opt/python/      # Python packages
       /opt/lib/         # unix libraries
       /opt/etc          # ODBC connection files odbcinst.ini and odbc.ini
   ```

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                   | Version            |
| ------------------------------------------------------ | ------------------ |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 6.21.0, < 7.0.0 |

### Providers

| Name                                                         | Version            |
| ------------------------------------------------------------ | ------------------ |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a                |
| <a name="provider_aws"></a> [aws](#provider_aws)             | >= 6.21.0, < 7.0.0 |

### Resources

| Name                                                                                                                                                                     | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudwatch_event_rule.weekly_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                             | resource    |
| [aws_cloudwatch_event_target.weekly_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)                  | resource    |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                   | resource    |
| [aws_iam_role.lambda_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                         | resource    |
| [aws_iam_role_policy_attachment.lambda\_\_managed_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.lambda_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)            | resource    |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                                  | resource    |
| [aws_lambda_function_event_invoke_config.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config)       | resource    |
| [aws_lambda_layer_version.case-notification-layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version)                     | resource    |
| [aws_lambda_permission.allow_weekly_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                                | resource    |
| [aws_secretsmanager_secret.case_notification_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                      | resource    |
| [aws_secretsmanager_secret.case_notification_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                    | resource    |
| [aws_secretsmanager_secret_version.case_notification_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)      | resource    |
| [aws_secretsmanager_secret_version.case_notification_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)    | resource    |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                    | resource    |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)  | resource    |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                             | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                            | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                              | data source |

### Inputs

| Name                                                                                                                                 | Description                                                                                                                           | Type           | Default                                                      | Required |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------ | :------: |
| <a name="input_database_user_name"></a> [database_user_name](#input_database_user_name)                                              | Database username with access to messaging database.                                                                                  | `string`       | n/a                                                          |   yes    |
| <a name="input_database_user_password"></a> [database_user_password](#input_database_user_password)                                  | Database password with access to messaging database.                                                                                  | `string`       | n/a                                                          |   yes    |
| <a name="input_rds_server_name"></a> [rds_server_name](#input_rds_server_name)                                                       | RDS Server name.                                                                                                                      | `string`       | n/a                                                          |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                       | Prefix applied to all resource names. Recommended to name by environemnt i.e. appname-dev, appname-test                               | `string`       | n/a                                                          |   yes    |
| <a name="input_sftp_hostname"></a> [sftp_hostname](#input_sftp_hostname)                                                             | Endpoint for sftp server.                                                                                                             | `string`       | n/a                                                          |   yes    |
| <a name="input_sftp_password"></a> [sftp_password](#input_sftp_password)                                                             | SFTP password.                                                                                                                        | `string`       | n/a                                                          |   yes    |
| <a name="input_sftp_username"></a> [sftp_username](#input_sftp_username)                                                             | SFTP username.                                                                                                                        | `string`       | n/a                                                          |   yes    |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)                                                                      | Subnet IDs to which lambda is associated. Note: must be associated with vpc_id!                                                       | `list(string)` | n/a                                                          |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                                  | VPC ID to for security group. Note: used implicitly through subnet references in lambda.                                              | `string`       | n/a                                                          |   yes    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                                                      | KMS Key Id to encrypt values. Defaults to AWS managed key for Secrets Manager if not set. Must allow lambda function to decrypt.      | `string`       | `""`                                                         |    no    |
| <a name="input_lambda_env_dry_run"></a> [lambda_env_dry_run](#input_lambda_env_dry_run)                                              | DRY_RUN lambda environment variable. Accepted values = True/False                                                                     | `string`       | `"False"`                                                    |    no    |
| <a name="input_lambda_env_log_level"></a> [lambda_env_log_level](#input_lambda_env_log_level)                                        | LOG_LEVEL lambda environment variable. Accepted values = INFO, ERROR, DEBUG, WARN                                                     | `string`       | `"INFO"`                                                     |    no    |
| <a name="input_lambda_env_max_batch_size"></a> [lambda_env_max_batch_size](#input_lambda_env_max_batch_size)                         | MAX_BATCH_SIZE lambda environment variable. Accepted values = integer numbers                                                         | `string`       | `"50"`                                                       |    no    |
| <a name="input_lambda_env_reported_service_types"></a> [lambda_env_reported_service_types](#input_lambda_env_reported_service_types) | REPORTED_SERVICE_TYPES lambda environment variable. Accepted values = comma separate entries encapsulated by parenthesis, see default | `string`       | `"('NNDM_1.1.3', 'NND_Case_Note', 'NBS_1.1.3_LDF', 'MVPS')"` |    no    |
| <a name="input_lambda_env_sftp_put_filepath"></a> [lambda_env_sftp_put_filepath](#input_lambda_env_sftp_put_filepath)                | SFTP_PUT_FILEPATH lambda environment variable. Accepted values = filepath with or without terminating '/'                             | `string`       | `""`                                                         |    no    |
| <a name="input_maximum_event_age_in_seconds"></a> [maximum_event_age_in_seconds](#input_maximum_event_age_in_seconds)                | Max Amount of time in seconds spent in queue for async invocation. Default = 3600 sec (1 hour)                                        | `number`       | `3600`                                                       |    no    |
| <a name="input_maximum_retry_attempts"></a> [maximum_retry_attempts](#input_maximum_retry_attempts)                                  | Number of times to retry Lambda should an error occur.                                                                                | `number`       | `2`                                                          |    no    |
| <a name="input_python_runtime"></a> [python_runtime](#input_python_runtime)                                                          | The version of python which runs the code. Note changing this may require a code change.                                              | `string`       | `"python3.12"`                                               |    no    |
| <a name="input_schedule_cron_expression"></a> [schedule_cron_expression](#input_schedule_cron_expression)                            | Cron format trigger schedule for Lambda function                                                                                      | `string`       | `"cron(0 0 ? * 1 *)"`                                        |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                        | Tags applied to lambda function.                                                                                                      | `map(string)`  | `{}`                                                         |    no    |
| <a name="input_timeout"></a> [timeout](#input_timeout)                                                                               | Timeout in seconds for lambda function. Default (600s = 10 minutes)                                                                   | `number`       | `600`                                                        |    no    |
| <a name="input_tmp_storage"></a> [tmp_storage](#input_tmp_storage)                                                                   | Amount of Lambda ephemeral storage (/tmp) in MB. Valid between 512 MB and 10,240 MB (10 GB)                                           | `number`       | `512`                                                        |    no    |

<!-- END_TF_DOCS -->
