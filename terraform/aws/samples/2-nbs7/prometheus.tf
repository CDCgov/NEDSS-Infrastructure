# module "prometheus_grafana" {
#   source = "../../app-infrastructure/aws-prometheus-grafana"

#   cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
#   eks_cluster_endpoint               = module.eks_nbs.eks_cluster_endpoint
#   eks_cluster_name                   = module.eks_nbs.eks_cluster_name
#   eks_aws_role_arn                   = var.aws_role_arn
#   oidc_provider_arn                  = module.eks_nbs.oidc_provider_arn
#   oidc_provider_url                  = module.eks_nbs.cluster_oidc_issuer_url
#   region                             = data.aws_region.current
#   tags                               = {}
#   values_file_path                   = "${path.module}/../.terraform/modules/dev.prometheus_grafana/terraform/aws/app-infrastructure/aws-prometheus-grafana/modules/prometheus-helm/values.yaml"
# }