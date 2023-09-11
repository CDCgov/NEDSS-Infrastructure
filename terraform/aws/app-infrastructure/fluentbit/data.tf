data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}
