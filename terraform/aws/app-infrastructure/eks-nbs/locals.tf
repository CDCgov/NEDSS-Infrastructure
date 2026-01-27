locals {
  eks_name            = var.name != "" ? var.name : "${var.resource_prefix}-eks"
  eks_iam_role_name   = var.name != "" ? "${var.name}-role" : "${var.resource_prefix}-eks-role"
  eks_node_group_name = var.name != "" ? "eks-nbs-main" : "${var.resource_prefix}-node-group-main"

  # Merge old single-value variables with new list variables for backward compatibility
  admin_roles = length(var.admin_role_arns) > 0 ? var.admin_role_arns : [var.aws_role_arn]

  readonly_roles = length(var.readonly_role_arns) > 0 ? var.readonly_role_arns : (
    var.readonly_role_arn != null ? [var.readonly_role_arn] : []
  )

  # Create access entries for admin roles
  admin_access_entries = {
    for idx, role_arn in local.admin_roles :
    "admin-role-${idx}" => {
      principal_arn = role_arn
      policy_associations = {
        admin-access = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Create access entries for readonly roles
  readonly_access_entries = {
    for idx, role_arn in local.readonly_roles :
    "readonly-role-${idx}" => {
      principal_arn = role_arn
      policy_associations = {
        readonly-access = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
