# Serial: 2024081301

locals {
  zone_id    = try(module.dns.zone_id["${module.dns.registered_domain_name}"], var.zone_id)
  lb_subnets = var.load_balancer_internal ? module.legacy-vpc.private_subnets : module.legacy-vpc.public_subnets
}

data "aws_region" "current" {}

module "nbs-legacy" {

  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/nbs-legacy?ref=release-7.11.0-rc1"

  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/development-infrastructure/nbs-legacy"

  #docker_image           = "${var.shared_services_accountid}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.docker_image}"
  docker_image = var.docker_image

  deploy_on_ecs          = var.deploy_on_ecs
  deploy_alb_dns_record  = var.deploy_alb_dns_record
  nbs_github_release_tag = var.nbs_github_release_tag
  ecs_cpu                = var.ecs_cpu
  ecs_memory             = var.ecs_memory
  ecs_subnets            = module.legacy-vpc.private_subnets
  subnet_ids             = module.legacy-vpc.private_subnets
  vpc_id                 = module.legacy-vpc.vpc_id

  # nbs6_ingress_vpc_cidr_blocks = [var.modern-cidr, var.legacy-cidr, var.shared_vpc_cidr_block]
  nbs6_ingress_vpc_cidr_blocks = [var.legacy-cidr, var.shared_vpc_cidr_block]

  nbs6_rdp_cidr_block          = [var.shared_vpc_cidr_block]

  # was using fixed naming for legacy 
  # resource_prefix              = "cdc-nbs-legacy"
  # instead of doing this we will build "prefix" with resource_prefix
  # name            = var.legacy-name
  #resource_prefix             = var.classic_resource_prefix
  resource_prefix = "${var.resource_prefix}-classic"

  # conditional use dns if created or input zone_id otherwise
  zone_id          = local.zone_id
  route53_url_name = var.route53_url_name
  tags             = var.tags
  domain_name      = var.domain_name
  create_cert      = var.create_cert

  artifacts_bucket_name          = var.artifacts_bucket_name
  deployment_package_key         = var.deployment_package_key
  nbs_db_dns                     = module.dns.nbs_db_dns
  kms_arn_shared_services_bucket = var.kms_arn_shared_services_bucket

  ## load balancer
  # use locals to pick private or public
  load_balancer_subnet_ids = local.lb_subnets
  load_balancer_type       = var.load_balancer_type
  internal                 = var.load_balancer_internal

  ### Only for EC2
  instance_type = var.instance_type
  ami           = var.ami
  ec2_key_name  = var.ec2_key_name
  #enable_user_data = var.ec2_enable_user_data

   # DB 
  odse_user = var.odse_user
  odse_pass = var.odse_pass
  rdb_user = var.rdb_user
  rdb_pass = var.rdb_pass
  srte_user = var.srte_user
  srte_pass = var.srte_pass

  # JVM and scheduled tasks
  java_memory = var.java_memory
  windows_scheduled_tasks = var.windows_scheduled_tasks
  phcrimporter_user = var.phcrimporter_user

  # delete these from future version if not used
  # public_subnet_ids      = module.legacy-vpc.public_subnets
  # legacy_vpc_id          = module.legacy-vpc.vpc_id
  # modern_vpc_id          = module.modernization-vpc.vpc_id
  # shared_vpc_cidr_block  = var.shared_vpc_cidr_block
  # legacy_resource_prefix = "cdc-nbs-legacy"
  # ec2_key_name           = var.ec2_key_name
  # db_instance_type       = var.db_instance_type
  # db_snapshot_identifier = var.db_snapshot_identifier
  # ignore_tags            = var.ignore_tags
}
