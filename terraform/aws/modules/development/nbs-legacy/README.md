# Terraform AWS Module: development/nbs-legacy

## Description

This module is used to deploy and configure development resources for NBS legacy services.

## Module Details

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 8.2 |
| <a name="module_alb_sg"></a> [alb\_sg](#module\_alb\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_app_server"></a> [app\_server](#module\_app\_server) | terraform-aws-modules/ec2-instance/aws | ~> 5.7 |
| <a name="module_app_sg"></a> [app\_sg](#module\_app\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.shared_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.alb_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.odse_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.odse_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.phcrimporter_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.rdb_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.rdb_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.srte_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.srte_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_ingress_rule.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rdp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_nbs_db_dns"></a> [nbs\_db\_dns](#input\_nbs\_db\_dns) | NBS database server dns | `string` | n/a | yes |
| <a name="input_nbs_github_release_tag"></a> [nbs\_github\_release\_tag](#input\_nbs\_github\_release\_tag) | Create URL and download Release Package. Default is always latest or Null | `string` | n/a | yes |
| <a name="input_odse_pass"></a> [odse\_pass](#input\_odse\_pass) | Password for odse database | `string` | n/a | yes |
| <a name="input_odse_user"></a> [odse\_user](#input\_odse\_user) | User for odse database | `string` | n/a | yes |
| <a name="input_rdb_pass"></a> [rdb\_pass](#input\_rdb\_pass) | Password for odse database | `string` | n/a | yes |
| <a name="input_rdb_user"></a> [rdb\_user](#input\_rdb\_user) | User for odse database | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Legacy resource prefix for resources created by this module | `string` | n/a | yes |
| <a name="input_srte_pass"></a> [srte\_pass](#input\_srte\_pass) | Password for odse database | `string` | n/a | yes |
| <a name="input_srte_user"></a> [srte\_user](#input\_srte\_user) | User for odse database | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | map(string) of tags to add to created resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID of virtual private cloud | `string` | n/a | yes |
| <a name="input_ami"></a> [ami](#input\_ami) | AMI for EC2 instance. (Defaul) Null will use latest Windows 2022 Core Base ami. Required if deploy\_on\_ecs == false. | `string` | `null` | no |
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | S3 bucket name used to store build artifacts. Required if deploy\_on\_ecs == false. | `string` | `""` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | If create\_cert == false, provide a certificate\_arn | `string` | `""` | no |
| <a name="input_create_cert"></a> [create\_cert](#input\_create\_cert) | Do you want to create a public AWS Certificate (if false (default), must provide certificate\_arn). Requires zone\_id to be set. | `bool` | `false` | no |
| <a name="input_daily_stop_nbs6"></a> [daily\_stop\_nbs6](#input\_daily\_stop\_nbs6) | Map(string) of detailing whether to stop nbs6 daily and at what server time. | `map(string)` | <pre>{<br/>  "enabled": "false",<br/>  "nbs_stop_time": "00:00:00am"<br/>}</pre> | no |
| <a name="input_deploy_alb_dns_record"></a> [deploy\_alb\_dns\_record](#input\_deploy\_alb\_dns\_record) | Deploy alb dns record | `bool` | `true` | no |
| <a name="input_deploy_on_ecs"></a> [deploy\_on\_ecs](#input\_deploy\_on\_ecs) | Deploy Classic NBS on ECS? | `bool` | `false` | no |
| <a name="input_deployment_package_key"></a> [deployment\_package\_key](#input\_deployment\_package\_key) | Deployment package S3 key for NBS application. Required if deploy\_on\_ecs == false. | `string` | `""` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker Image for Classic NBS | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for hosted zone (ex. dev-app.my-domain.com). Required if create\_cert == true | `string` | `""` | no |
| <a name="input_ec2_key_name"></a> [ec2\_key\_name](#input\_ec2\_key\_name) | EC2 key pair to manage instance. Required if deploy\_on\_ecs == false. | `string` | `""` | no |
| <a name="input_ecs_cpu"></a> [ecs\_cpu](#input\_ecs\_cpu) | Classic NBS ECS CPU Configuration | `string` | `"2048"` | no |
| <a name="input_ecs_memory"></a> [ecs\_memory](#input\_ecs\_memory) | Classic NBS ECS Memory Configuration | `string` | `"8192"` | no |
| <a name="input_ecs_subnets"></a> [ecs\_subnets](#input\_ecs\_subnets) | Classic NBS ECS Subnets Configuration | `list(any)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for EC2 instance. Required if deploy\_on\_ecs == false. | `string` | `""` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the LB will be internal. Defaults to `false` | `bool` | `null` | no |
| <a name="input_java_memory"></a> [java\_memory](#input\_java\_memory) | Memory for Wildfly server to run Java (NOTE should not exceed 70% of VM memory) | `string` | `"4g"` | no |
| <a name="input_kms_arn_shared_services_bucket"></a> [kms\_arn\_shared\_services\_bucket](#input\_kms\_arn\_shared\_services\_bucket) | KMS key arn used to encrypt shared services s3 bucket | `string` | `""` | no |
| <a name="input_load_balancer_subnet_ids"></a> [load\_balancer\_subnet\_ids](#input\_load\_balancer\_subnet\_ids) | Subnet Id to be used when creating load balancer. Conflicts with subnet\_mapping (which take precedence if set). | `list(any)` | `null` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of load balancer to create. Possible values are `application` or `network`. The default value is `network` | `string` | `"network"` | no |
| <a name="input_local_bucket"></a> [local\_bucket](#input\_local\_bucket) | Bucket exists in same account where infrastructure is being deployed | `bool` | `false` | no |
| <a name="input_max_meta_space_size"></a> [max\_meta\_space\_size](#input\_max\_meta\_space\_size) | Max non-heap memory area used to store metadata such as class definitions, method data, and field data. | `string` | `"512M"` | no |
| <a name="input_nbs6_ingress_vpc_cidr_blocks"></a> [nbs6\_ingress\_vpc\_cidr\_blocks](#input\_nbs6\_ingress\_vpc\_cidr\_blocks) | List of CIDR blocks which will have access to nbs6 instance | `list(any)` | `[]` | no |
| <a name="input_nbs6_rdp_cidr_block"></a> [nbs6\_rdp\_cidr\_block](#input\_nbs6\_rdp\_cidr\_block) | CIDR block in for RDP access | `list(any)` | `[]` | no |
| <a name="input_param_store_key_id"></a> [param\_store\_key\_id](#input\_param\_store\_key\_id) | (optional) KMS key id used to encrypt parameter store SecureString to be read by EC2 instance | `string` | `null` | no |
| <a name="input_phcrimporter_user"></a> [phcrimporter\_user](#input\_phcrimporter\_user) | User needed to run phcrimporter batch job (leave\_default=preserve Wildfly default) | `string` | `"leave_default"` | no |
| <a name="input_route53_url_name"></a> [route53\_url\_name](#input\_route53\_url\_name) | URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com). Requires zone\_id to be set. | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet Id to be used when creating EC2 instance | `list(any)` | `[]` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | A list of subnet mapping blocks describing subnets to attach to load balancer. Map keys = subnet\_id, private\_ipv4\_address. Conflicts with load\_balancer\_subnet\_ids (subnet\_mapping takes precedence). | `list(map(string))` | `[]` | no |
| <a name="input_update_route53_a_record"></a> [update\_route53\_a\_record](#input\_update\_route53\_a\_record) | Updates route53 A record | `bool` | `false` | no |
| <a name="input_windows_scheduled_tasks"></a> [windows\_scheduled\_tasks](#input\_windows\_scheduled\_tasks) | Scheduled tasks in semicolon-separated list providing, note the trailing ';' - filename, scriptPathFromWorkDir, dailyStartTime, dailyStopTime, frequencyDays, frequencyHours, frequencyMinutes; | `string` | `"ELRImporter.bat,, 6:00:00am, 6:00:00pm, 0, 0, 2; MsgOutProcessor.bat,, 6:00:00am, 7:00:00pm, 0, 0 , 2; UserProfileUpdateProcess.bat, retired\\, 12:00:00am,, 1, 0, 0; DeDuplicationSimilarBatchProcess.bat, retired\\, 7:00:00pm,, 1, 0 , 0; covid19ETL.bat,, 5:00:00am,, 1, 0 , 0; PHCRImporter.bat,, 6:00:00am, 7:00:00pm, 0, 1 , 0;"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 Hosted Zone Id. Requires route53\_url\_name to be set. | `string` | `""` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nbs_app_alb"></a> [nbs\_app\_alb](#output\_nbs\_app\_alb) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->
