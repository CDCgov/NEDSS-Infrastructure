module "eks_nbs" {
  source                     = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/eks-nbs?ref=v1.2.2-DEV"
  resource_prefix            = var.resource_prefix
  subnets                    = local.list_subnet_ids
  vpc_id                     = data.aws_vpc.vpc_1.id
  aws_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  sso_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.sso_admin_role_name}"
  desired_nodes_count        = var.eks_desired_nodes_count
  max_nodes_count            = var.eks_max_nodes_count
  min_nodes_count            = var.eks_min_nodes_count
  instance_type              = var.eks_instance_type
  ebs_volume_size            = var.eks_disk_size
  use_ecr_pull_through_cache = var.use_ecr_pull_through_cache
  external_cidr_blocks       = var.external_cidr_blocks
}
