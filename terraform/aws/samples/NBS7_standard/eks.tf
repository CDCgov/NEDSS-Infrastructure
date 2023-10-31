module "eks_nbs" {
  source              = "../app-infrastructure/eks-nbs"
  resource_prefix     = var.resource_prefix
  subnets             = module.modernization-vpc.private_subnets
  vpc_id              = module.modernization-vpc.vpc_id
  aws_role_arn        = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  sso_role_arn        = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  desired_nodes_count = var.eks_desired_nodes_count
  max_nodes_count     = var.eks_max_nodes_count
  min_nodes_count     = var.eks_min_nodes_count
  instance_type       = var.eks_instance_type
  ebs_volume_size     = var.eks_disk_size
}
