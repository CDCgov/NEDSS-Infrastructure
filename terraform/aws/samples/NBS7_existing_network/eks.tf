# Serial: 2024081201

module "eks_nbs" {
<<<<<<< HEAD
  #source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/eks-nbs?ref=v1.2.14"
=======
  #source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/eks-nbs?ref=v1.2.12"
>>>>>>> deb6bf37e2d8bb31478dc2aec76f836dcdf0b02d
  #source              = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/eks-nbs"
  source              = "../app-infrastructure/eks-nbs"
  #subnets                    = module.modernization-vpc.private_subnets
  #vpc_id                     = module.modernization-vpc.vpc_id
  subnets                    = var.modernization-vpc-private-subnets
  #vpc_id                     = var.modernization-vpc-id
  vpc_id                     = data.aws_vpc.vpc_1.id
  aws_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  sso_role_arn               = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
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
