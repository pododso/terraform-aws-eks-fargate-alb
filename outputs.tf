output "alb_ingress_controller_service_account_iam_role_arn" {
  description = "ARN of the IAM Role to be attached to the alb-ingress-controller serviceaccount object"
  value = aws_iam_role.iam_role_alb_ingress_controller_service_account.arn
}

output "cluster_security_group_id" {
  description = "Security Group ID used by the cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}

output "fargate_profile_iam_role_arn" {
  description = "ARN of the IAM role attached to the fargate profiles"
  value = aws_iam_role.iam_role_fargate_profile.arn
}
