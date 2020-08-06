# terraform-aws-eks-fargate-alb
Module for managing EKS clusters using Fargate profiles.
Includes provisions for creating the IAM service role to be used by the AWS ALB Ingress Controller service account.
Does not include provisions for node groups.

## Features
* Includes an IAM Assume Role Policy document and Role for use of the `aws-alb-ingress-controller` service account
  * OIDC Thumbprint for `oidc.eks.[region].amazonaws.com` needs to be supplied. See references for documentation
  * IAM Policy for the ALB Ingress Controller Role needs to be supplied. See references for documentation
* Readily provisions a fargate profile for the namespaces `kube_system` and `default`

## Caveats
* Deploying the EKS Cluster by default configures the coredns pods to run on EC2 instances. Edit the coredns deployment to remove the `eks.amazonaws.com/compute-type : ec2` annotation to deploy the coredns pods in fargate
  ```
  kubectl edit deployment coredns -n kube-system
  ```

## Requirements
| Name      | Version   |
|-----------|-----------|
| terraform | >=0.12.24 |
| aws       | ~>3.0     |

## References
* [Getting started with AWS Fargate using Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html)
* [ALB Ingress Controller on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
* [Obtaining the Root CA Thumbprint for an OpenID Connect Identity Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html)
