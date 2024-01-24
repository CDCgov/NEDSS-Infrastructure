output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enable_irsa = true"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}


output "cluster_certificate_authority_data" {
  description = "TBase64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}


output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_aws_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "precreated_observability_namespace_name" {
  description = "Name of the observability namespace"
  value       =   kubernetes_namespace.observability.id # var.observability_namespace  # 
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}