
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

variable "k8s_the_eks_cluster_name"{
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
  eks_node_groups_iam_role_name = "k8s_eks_node_groups_iam_role_name_${var.random_pet}"
  eks_node_group_name = "k8s_eks_node_group_name_${var.random_pet}"
}

# Resource: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
/*
# Create IAM role for EKS Node Group
resource "aws_iam_role" "the_eks_node_groups_iam_role" {
  # The name of the role
  name = local.eks_node_groups_iam_role_name

  # The policy that grants an entity permission to assume the role.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }, 
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Resource: aws_iam_role_policy_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

resource "aws_iam_role_policy_attachment" "the_amazon_eks_worker_node_policy_attachment" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

  # The role the policy should be applied to
  role = aws_iam_role.the_eks_node_groups_iam_role.name
}

resource "aws_iam_role_policy_attachment" "the_amazon_eks_cni_policy_attachment" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

  # The role the policy should be applied to
  role = aws_iam_role.the_eks_node_groups_iam_role.name
}

resource "aws_iam_role_policy_attachment" "the_amazon_ec2_container_registry_read_only_policy_attachment" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  # The role the policy should be applied to
  role = aws_iam_role.the_eks_node_groups_iam_role.name
}

# Resource: aws_eks_node_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group

resource "aws_eks_node_group" "the_eks_nodes_group" {
  # Name of the EKS Cluster.
  cluster_name = var.k8s_the_eks_cluster_name

  # Name of the EKS Node Group.
  node_group_name = local.eks_node_group_name

  # Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = aws_iam_role.the_eks_node_groups_iam_role.arn

  # Identifiers of EC2 Subnets to associate with the EKS Node Group. 
  # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME 
  # (where CLUSTER_NAME is replaced with the name of the EKS Cluster).
  subnet_ids = [
    var.k8s_the_subnet_private_1_id,
    var.k8s_the_subnet_private_2_id
  ]

  # Configuration block with scaling settings
  scaling_config {
    # Desired number of worker nodes.
    desired_size = 1

    # Maximum number of worker nodes.
    max_size = 1

    # Minimum number of worker nodes.
    min_size = 1
  }

  # Type of Amazon Machine Image (AMI) associated with the EKS Node Group.
  # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"

  # Type of capacity associated with the EKS Node Group. 
  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # Disk size in GiB for worker nodes
  disk_size = 20

  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false

  # List of instance types associated with the EKS Node Group
  instance_types = ["t3.medium"] #m5.large

  labels = {
    role = local.eks_node_group_name
  }

  # Kubernetes version
  version = "1.27"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.the_amazon_eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.the_amazon_eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.the_amazon_ec2_container_registry_read_only_policy_attachment,    
  ]
}

output "k8s_the_eks_node_groups_iam_role_id" {   
  value       = aws_iam_role.the_eks_node_groups_iam_role.id
  description = "Eks node groups iam role Id"
}

output "k8s_the_amazon_ec2_container_registry_read_only_policy_attachment_id" {   
  value       = aws_iam_role_policy_attachment.the_amazon_ec2_container_registry_read_only_policy_attachment.id
  description = "Amazon ec2 container registry read only policy attachment"
}

output "k8s_the_amazon_eks_cni_policy_attachment_id" {   
  value       = aws_iam_role_policy_attachment.the_amazon_eks_cni_policy_attachment.id
  description = "Amazon eks cni policy attachment"
}

output "k8s_the_amazon_eks_worker_node_policy_attachment_id" {   
  value       = aws_iam_role_policy_attachment.the_amazon_eks_worker_node_policy_attachment.id
  description = "Amazon eks worker node policy attachment"
}

output "k8s_the_eks_nodes_group_id" {   
  value       = aws_eks_node_group.the_eks_nodes_group.id
  description = "Eks nodes group Id"
}
*/