module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnets

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
    
  }

  eks_managed_node_groups = {
      main = {
        name         = "eks-nbs-main"
        min_size     = var.min_nodes_count
        max_size     = var.max_nodes_count
        desired_size = var.desired_nodes_count
        disk_size      = var.ebs_volume_size
      }
      
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = var.aws_role_arn
      username = "role"
      groups   = ["system:masters"]
    },
    {
      rolearn  = var.sso_role_arn
      username = "adminssorole"
      groups   = ["system:masters"]
    }
  ]
}
