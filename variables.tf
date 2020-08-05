## General

variable "tags" {
  type        = map(string)
  description = "Mapping of tags to apply to all resources in this module"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of the cluster, also used in naming the other resources in this module"
}

## IAM

variable "oidc_thumbprint" {
  type = string
  description = "OpenID Connect thumbprint of 'oidc.eks.[region].amazonaws.com'"
}

## EKS

variable "eks_version" {
  type = string
  description = "EKS version of the cluster to be deployed"
}

variable "cluster_subnet_ids" {
  type = list(string)
  description = "List of VPC subnet IDs where the EKS cluster will be deployed"
}

variable "fargate_subnet_ids" {
  type = list(string)
  description = "List of VPC subnet IDs where the Fargate profile will deploy nodes in"
}

variable "namespaces" {
  type = list(string)
  description = "List of additional namespaces that will be deployed. A fargate profile will be provisioned for each namespace in the list"
}
