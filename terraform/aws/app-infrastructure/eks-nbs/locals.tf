locals {
  eks_name = var.name != "" ? var.name : "${var.resource_prefix}-eks"
  eks_iam_role_name = var.name != "" ? "${var.name}-role" : "${var.resource_prefix}-eks-role"
  eks_node_group_name = var.name != "" ? "eks-nbs-main" : "${var.resource_prefix}-node-group-main"
}