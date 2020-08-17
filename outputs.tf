output "alb_ingress_controller_service_account_iam_role_arn" {
  description = "ARN of the IAM Role to be attached to the alb-ingress-controller serviceaccount object"
  value = aws_iam_role.iam_role_alb_ingress_controller_service_account.arn
}

output "cluster_security_group_id" {
  description = "Security Group ID used by the cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "OpenID Connect Provider ARN of the EKS Cluster"
  value       = aws_iam_openid_connect_provider.iam_oidc_provider.arn
}

output "oidc_provicer_url" {
  description = "OpenID Connect Provider URL of the EKS Cluster"
  value       = aws_iam_openid_connect_provider.iam_oidc_provider.url
}
