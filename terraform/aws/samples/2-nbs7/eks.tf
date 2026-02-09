module "eks_nbs" {
  source       = "../../app-infrastructure/eks-nbs"
  subnets      = data.aws_subnets.nbs7.ids
  vpc_id       = data.aws_vpc.nbs7.id
  aws_role_arn = var.aws_role_arn
  admin_role_arns = concat(var.admin_role_arns,[var.aws_role_arn])  
  readonly_role_arn = var.readonly_role_arn
  readonly_role_arns            = concat(var.readonly_role_arns, [var.readonly_role_arn])
  desired_nodes_count          = var.eks_desired_nodes_count
  max_nodes_count              = var.eks_max_nodes_count
  min_nodes_count              = var.eks_min_nodes_count
  instance_type                = var.eks_instance_type
  ebs_volume_size              = var.eks_disk_size
  external_cidr_blocks         = var.external_cidr_blocks
  allow_endpoint_public_access = var.eks_allow_endpoint_public_access
  resource_prefix              = "${var.resource_prefix}"
  deploy_argocd_helm           = var.deploy_argocd_helm
  cluster_version              = var.eks_cluster_version
  kms_key_administrators       = var.kms_key_administrators
  cert_manager_hosted_zone_arns = [
    "arn:aws:route53:::hostedzone/${data.aws_route53_zone.root.zone_id}"
  ]
}
