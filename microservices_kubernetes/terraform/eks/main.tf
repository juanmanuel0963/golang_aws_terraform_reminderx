
#############################################################################
# VARIABLES
#############################################################################

variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "random_pet"{
  type    = string
}
/*
variable "k8s_the_vpc_id"{
  type    = string
}

variable "k8s_the_subnet_public_1_id"{
  type    = string
}

variable "k8s_the_subnet_public_2_id"{
  type    = string
}

variable "k8s_the_subnet_private_1_id"{
  type    = string
}

variable "k8s_the_subnet_private_2_id"{
  type    = string
}
*/
#############################################################################
# PROVIDERS
#############################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3.0"
    }
  }
}

provider "aws" {
  region = var.region
  //access_key = var.access_key
  //secret_key = var.secret_key
}

locals {
  eks_iam_role_name = "k8s_eks_iam_role_${var.random_pet}"
  eks_cluster_name  = "k8s_eks_cluster_${var.random_pet}"
}

# Resource: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
/*
resource "aws_iam_role" "the_eks_iam_role" {
  # The name of the role
  name = local.eks_iam_role_name

  # The policy that grants an entity permission to assume the role.
  # Used to access AWS resources that you might not normally have access to.
  # The role that Amazon EKS will use to create AWS resources for Kubernetes clusters
  assume_role_policy = <<POLICY
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
POLICY
}

# Resource: aws_iam_role_policy_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

resource "aws_iam_role_policy_attachment" "k8s_the_amazon_eks_cluster_policy_attachment" {
  # The ARN of the policy you want to apply
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # The role the policy should be applied to
  role = aws_iam_role.the_eks_iam_role.name
}

# Resource: aws_eks_cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

resource "aws_eks_cluster" "k8s_the_eks_cluster" {
  # Name of the cluster.
  name = local.eks_cluster_name

  # The Amazon Resource Name (ARN) of the IAM role that provides permissions for 
  # the Kubernetes control plane to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.the_eks_iam_role.arn

  # Desired Kubernetes master version
  version = "1.27"

  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = false

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true

    # Must be in at least two different availability zones
    subnet_ids = [
      var.k8s_the_subnet_public_1_id,
      var.k8s_the_subnet_public_2_id,
      var.k8s_the_subnet_private_1_id,
      var.k8s_the_subnet_private_2_id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8s_the_amazon_eks_cluster_policy_attachment
  ]
}

output "k8s_the_eks_iam_role_policy_attachment_id" {   
  value       = aws_iam_role_policy_attachment.k8s_the_amazon_eks_cluster_policy_attachment.id
  description = "Eks iam role policy attachment Id"
}

output "k8s_the_eks_cluster_id" {   
  value       = aws_eks_cluster.k8s_the_eks_cluster.id
  description = "Eks cluster Id"
}

output "k8s_the_eks_cluster_name" {   
  value       = aws_eks_cluster.k8s_the_eks_cluster.name
  description = "Eks cluster Name"
}

*/