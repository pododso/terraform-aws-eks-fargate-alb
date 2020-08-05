output "alb_ingress_controller_service_account_iam_role_arn" {
  description = "ARN of the IAM Role to be attached to the alb-ingress-controller serviceaccount object"
  value = aws_iam_role.iam_role_alb_ingress_controller_service_account.arn
}
