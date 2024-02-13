module "nbs6" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/nbs-legacy?ref=CNPT-1628-alb-to-nlb"
  
  # Global module flags
  resource_prefix = var.resource_prefix
  deploy_on_ecs = true
  create_cert = false
  vpc_id = data.aws_vpc.vpc_1.id
  tags                   = var.tags

  # ECS settings
  ecs_subnets = data.aws_subnet.ecs_subnet.id
  docker_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.docker_image}"
  ecs_cpu = var.ecs_cpu
  ecs_memory = var.ecs_memory
  nbs6_ingress_vpc_cidr_blocks = var.nbs6_ingress_vpc_cidr_blocks
  nbs_db_dns = module.rds.nbs_db_address
  kms_arn_shared_services_bucket = module.kms.kms_key_arn
  

  # load balancer settings
  load_balancer_type = var.load_balancer_type
  subnet_mapping = [
    {      
      private_ipv4_address = var.ecs_private_ipv4_address
      subnet_id = data.aws_subnet.ecs_subnet.id      
    }
  ]
  certificate_arn = "arn:aws:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:certificate/${var.certificate_id}"   
}