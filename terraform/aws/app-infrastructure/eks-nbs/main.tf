module "eks" {
  source                        = "terraform-aws-modules/eks/aws"
  version                       = "21.9.0"
  kms_key_enable_default_policy = var.kms_key_enable_default_policy
  kms_key_administrators        = coalescelist(var.kms_key_administrators, [try(data.aws_iam_session_context.current.issuer_arn, "")])
  kms_key_owners                = var.kms_key_owners

  # Set cluster info
  cluster_name                   = local.eks_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = var.allow_endpoint_public_access

  # Set VPC/Subnets
  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  # Cluster addons, ebs csi driver
  # cluster_addons = {
  #   aws-ebs-csi-driver = {
  #     resolve_conflicts_on_create = "OVERWRITE"
  #     most_recent       = true
  #   }
  # }

  # Set node group instance types
  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]

  }

  # Create node groups with config
  eks_managed_node_groups = {
    main = {
      name                     = local.eks_node_group_name
      iam_role_use_name_prefix = false # Set to false to allow custom name, helping prevent character limit
      iam_role_name            = local.eks_iam_role_name
      iam_role_additional_policies = {
        AmazonElasticContainerRegistryPublicFullAccess = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
        PullThroughCacheRule                           = "${aws_iam_policy.eks_permissions.arn}"

      }
      min_size     = var.min_nodes_count
      max_size     = var.max_nodes_count
      desired_size = var.desired_nodes_count
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = var.ebs_volume_size
            volume_type = "gp3"
          }
        }
      }
    }

  }


  access_entries = merge(
    {
      admin-role = {
        principal_arn = var.aws_role_arn

        policy_associations = {
          admin-access = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    try(length(var.readonly_role_arn) > 0, false) ? {
      readonly-role = {
        principal_arn = var.readonly_role_arn

        policy_associations = {
          readonly-access = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    } : {}
  )
}


#Additional EKS permissions
resource "aws_iam_policy" "eks_permissions" {
  name        = "${local.eks_name}-additional-policy"
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
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : ["*"]
      }

    ]
  })
}

# Additional ingress for cluster api access
resource "aws_vpc_security_group_ingress_rule" "example" {
  for_each          = toset(var.external_cidr_blocks)
  security_group_id = module.eks.cluster_security_group_id

  cidr_ipv4   = each.key
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}


