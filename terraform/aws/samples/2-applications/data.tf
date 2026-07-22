data "aws_eks_cluster" "selected" {
  name = var.aws_eks_cluster_name == null ? "${var.resource_prefix}-eks" : var.aws_eks_cluster_name
}