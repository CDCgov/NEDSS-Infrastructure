module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  # Set cluster info
  cluster_name    = local.eks_name  
  cluster_version = var.cluster_version
  cluster_endpoint_public_access  = true

  # Set VPC/Subnets
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnets

  # Cluster addons, ebs csi driver
  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }

    aws-efs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
      role_name         = "${module.efs_cni_irsa_role.name}"
    }
  }

  # Set node group instance types
  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
    
  }

  # Create node groups with config
  eks_managed_node_groups = {
      main = {
        name         = local.eks_node_group_name
        iam_role_use_name_prefix = false # Set to false to allow custom name, helping prevent character limit
        iam_role_name = local.eks_iam_role_name
        iam_role_additional_policies = {
          AmazonElasticContainerRegistryPublicFullAccess  = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
          PullThroughCacheRule = "${aws_iam_policy.eks_permissions.arn}"
          
        }
        min_size     = var.min_nodes_count
        max_size     = var.max_nodes_count
        desired_size = var.desired_nodes_count
        block_device_mappings = {
            xvda = {
              device_name = "/dev/xvda"
              ebs = {
                volume_size           = var.ebs_volume_size
                volume_type           = "gp3"                
                }
              }
          }   
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

#Additional EKS permissions
resource "aws_iam_policy" "eks_permissions" {
  name = "${local.eks_name}-additional-policy"
  path        = "/"
  description = "Additional Permissions required for EKS cluster ${local.eks_name}"
  
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchImportUpstreamImage",
          "ecr:CreatePullThroughCacheRule",
          "ecr:CreateRepository",
          "ecr:TagResource"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
