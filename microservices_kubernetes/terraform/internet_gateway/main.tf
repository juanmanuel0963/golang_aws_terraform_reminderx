
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
  internet_gateway_name = "k8s_internet_gateway_${var.random_pet}"
}


# Resource: aws_internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
/*
resource "aws_internet_gateway" "k8s_the_internet_gateway" {
  # The VPC ID to create in.
  vpc_id = var.k8s_the_vpc_id

  # A map of tags to assign to the resource.
  tags = {
    Name = local.internet_gateway_name
  }
}

output "k8s_the_internet_gateway_id" {  
  description = "Internet Gateway Id"
  value       = aws_internet_gateway.k8s_the_internet_gateway.id
}

*/