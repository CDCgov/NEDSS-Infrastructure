# Serial: 2024081201

module "eks_nbs" {
  #source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/eks-nbs?ref=v1.2.14"
  #source              = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/eks-nbs"
  source              = "../app-infrastructure/eks-nbs"
  subnets                    = module.modernization-vpc.private_subnets
  vpc_id                     = module.modernization-vpc.vpc_id
  aws_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  sso_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  # optional role to authenticate into the EKS cluster for ReadOnly, leave empty "" if not needed
  readonly_role_arn          = ""
  #sso_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.sso_admin_role_name}"
  desired_nodes_count        = var.eks_desired_nodes_count
  max_nodes_count            = var.eks_max_nodes_count
  min_nodes_count            = var.eks_min_nodes_count
  instance_type              = var.eks_instance_type
  ebs_volume_size            = var.eks_disk_size
  resource_prefix            = var.resource_prefix
  use_ecr_pull_through_cache = var.use_ecr_pull_through_cache
  external_cidr_blocks       = var.external_cidr_blocks
  allow_endpoint_public_access  = var.eks_allow_endpoint_public_access
}
