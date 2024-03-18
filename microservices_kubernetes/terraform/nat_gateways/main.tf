
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
variable "k8s_the_eip_nat1_id"{
  type    = string
}

variable "k8s_the_eip_nat2_id"{
  type    = string
}

variable "k8s_the_subnet_public_1_id"{
  type    = string
}

variable "k8s_the_subnet_public_2_id"{
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
  gateway_name = "k8s_nat_gateways_${var.random_pet}"
}

# Resource: aws_nat_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
/*
resource "aws_nat_gateway" "k8s_the_nat_gateway_1" {
  # The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = var.k8s_the_eip_nat1_id

  # The Subnet ID of the subnet in which to place the gateway.
  subnet_id = var.k8s_the_subnet_public_1_id

  # A map of tags to assign to the resource.
  tags = {
    Name = "K8s NAT 1"
  }
}

resource "aws_nat_gateway" "k8s_the_nat_gateway_2" {
  # The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = var.k8s_the_eip_nat2_id

  # The Subnet ID of the subnet in which to place the gateway.
  subnet_id = var.k8s_the_subnet_public_2_id

  # A map of tags to assign to the resource.
  tags = {
    Name = "K8s NAT 2"
  }
}


output "k8s_the_nat_gateway_1_id" {  
  description = "Nat Gateway 1 Id"
  value       = aws_nat_gateway.k8s_the_nat_gateway_1.id
}

output "k8s_the_nat_gateway_2_id" {  
  description = "Nat Gateway 2 Id"
  value       = aws_nat_gateway.k8s_the_nat_gateway_2.id
}

*/