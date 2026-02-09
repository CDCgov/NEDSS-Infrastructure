data "aws_eks_cluster" "selected" {
  name = var.aws_eks_cluster_name ? "${var.resource_prefix}-eks" : var.aws_eks_cluster_name
}