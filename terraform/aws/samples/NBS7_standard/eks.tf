# Serial: 2023080201

module "eks_nbs" {
  source       = "../app-infrastructure/eks-nbs"
  subnets      = module.modernization-vpc.private_subnets
  vpc_id       = module.modernization-vpc.vpc_id
  aws_role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  sso_role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
}
