# Resource: aws_subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet


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
  subnets_name = "k8s_subnets_${var.random_pet}"
  tag_name = "kubernetes.io/cluster/k8s_eks_cluster_${var.random_pet}"
}
/*
resource "aws_subnet" "k8s_the_subnet_public_1" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  # The CIDR block for the subnet.
  cidr_block = "192.168.0.0/18"

  # The AZ for the subnet.
  availability_zone = "us-east-1a"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name = "k8s_public-us-east-1a"
    //"kubernetes.io/cluster/k8s_eks_cluster_kite"        = "shared"
    "${local.tag_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "k8s_the_subnet_public_2" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  # The CIDR block for the subnet.
  cidr_block = "192.168.64.0/18"

  # The AZ for the subnet.
  availability_zone = "us-east-1b"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name = "k8s_public-us-east-1b"
    //"kubernetes.io/cluster/k8s_eks_cluster_kite"        = "shared"
    "${local.tag_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "k8s_the_subnet_private_1" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  # The CIDR block for the subnet.
  cidr_block = "192.168.128.0/18"

  # The AZ for the subnet.
  availability_zone = "us-east-1a"

  # A map of tags to assign to the resource.
  tags = {
    Name = "k8s_private-us-east-1a"
    //"kubernetes.io/cluster/k8s_eks_cluster_kite"        = "shared"
    "${local.tag_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "k8s_the_subnet_private_2" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  # The CIDR block for the subnet.
  cidr_block = "192.168.192.0/18"

  # The AZ for the subnet.
  availability_zone = "us-east-1b"

  # A map of tags to assign to the resource.
  tags = {
    Name = "k8s_private-us-east-1b"
    //"kubernetes.io/cluster/k8s_eks_cluster_kite"        = "shared"
    "${local.tag_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

output "k8s_the_subnet_public_1_id" {
  value       = aws_subnet.k8s_the_subnet_public_1.id
  description = "Subnet public 1 Id"
}

output "k8s_the_subnet_public_2_id" {
  value       = aws_subnet.k8s_the_subnet_public_2.id
  description = "Subnet public 2 Id"
}

output "k8s_the_subnet_private_1_id" {
  value       = aws_subnet.k8s_the_subnet_private_1.id
  description = "Subnet private 1 Id"
}

output "k8s_the_subnet_private_2_id" {
  value       = aws_subnet.k8s_the_subnet_private_2.id
  description = "Subnet private 2 Id"
}

*/