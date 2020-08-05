resource "aws_iam_role" "iam_role_cluster" {
  name               = "${var.name}-cluster-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_cluster.id
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.iam_role_cluster.id
}

resource "aws_iam_role" "iam_role_fargate_profile" {
  name               = "${var.name}-fargate-profile-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_fargate_profile_AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.iam_role_fargate_profile.id
}

resource "aws_iam_openid_connect_provider" "iam_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "alb_ingress_controller_service_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.iam_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:alb-ingress-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.iam_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "iam_role_alb_ingress_controller_service_account" {
  assume_role_policy = data.aws_iam_policy_document.alb_ingress_controller_service_account_assume_role_policy.json
  name               = "${var.name}-alb-ingress-controller-service-account-role"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_alb_ingress_controller_service_account_ALBIngressControllerIAMPolicy" {
  policy_arn = var.alb_ingress_controller_iam_policy_arn
  role       = aws_iam_role.iam_role_alb_ingress_controller_service_account.id
}

resource "aws_eks_cluster" "eks_cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.iam_role_policy_attachment_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.iam_role_policy_attachment_cluster_AmazonEKSServicePolicy,
    aws_iam_role.iam_role_cluster
  ]

  name                      = "${var.name}-cluster"
  role_arn                  = aws_iam_role.iam_role_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version                   = var.eks_version
  tags                      = var.tags

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.cluster_subnet_ids
  }
}

resource "aws_eks_fargate_profile" "eks_fargate_profile_system" {
  cluster_name           = aws_eks_cluster.eks_cluster.id
  fargate_profile_name   = "${var.name}-fargate-profile-system"
  pod_execution_role_arn = aws_iam_role.iam_role_fargate_profile.arn
  subnet_ids             = var.fargate_subnet_ids
  tags                   = var.tags

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }
}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  for_each = toset(var.namespaces)

  cluster_name           = aws_eks_cluster.eks_cluster.id
  fargate_profile_name   = "${var.name}-fargate-profile-${each.key}"
  pod_execution_role_arn = aws_iam_role.iam_role_fargate_profile.arn
  subnet_ids             = var.fargate_subnet_ids
  tags                   = var.tags

  selector {
    namespace = each.key
  }
}
