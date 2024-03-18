
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
  vpc_name = "k8s_vpc_${var.random_pet}"
}

#############################################################################
# RESOURCES
#############################################################################  
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
/*
resource "aws_vpc" "k8s_the_vpc" {

  # The CIDR block for the VPC.
  cidr_block = "192.168.0.0/16"

  # Makes your instances shared on the host.
  instance_tenancy = "default"

  # Required for EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = true

  # Required for EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = true

  # Enable/disable ClassicLink for the VPC. Error: Unsupported argument
  #enable_classiclink = false

  # Enable/disable ClassicLink DNS Support for the VPC. Error: Unsupported argument
  #enable_classiclink_dns_support = false

  # Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC.
  assign_generated_ipv6_cidr_block = false

  # A map of tags to assign to the resource.
  tags = {
    Name = local.vpc_name
  }

}

output "k8s_the_vpc_id" {
  value       = aws_vpc.k8s_the_vpc.id
  description = "VPC Id"
}

*/