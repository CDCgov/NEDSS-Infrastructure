locals {
    eks_cluster_endpoint = data.aws_eks_cluster.selected.endpoint
    cluster_certificate_authority_data = data.aws_eks_cluster.selected.certificate_authority
    eks_cluster_name = data.aws_eks_cluster.selected.name
}