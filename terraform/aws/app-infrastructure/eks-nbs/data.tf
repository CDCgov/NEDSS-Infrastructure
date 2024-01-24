data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}
## this was commented out
# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

########## EXTERNALIZE PROVIDER

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_name 
}