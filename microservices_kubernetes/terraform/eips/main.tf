
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

variable "k8s_the_internet_gateway"{
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
  eips_name = "k8s_eips_${var.random_pet}"
}

# Resource: aws_eip
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
/*
resource "aws_eip" "k8s_the_eip_nat1" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [var.k8s_the_internet_gateway]

  # A map of tags to assign to the resource.
  tags = {
    Name = "K8s EIP 1"
  }
}

resource "aws_eip" "k8s_the_eip_nat2" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [var.k8s_the_internet_gateway]

  # A map of tags to assign to the resource.
  tags = {
    Name = "K8s EIP 2"
  }  
}

output "k8s_the_eip_nat1_public_ip" {
  value       =  aws_eip.k8s_the_eip_nat1.public_ip
  description = "Elastic Public IP Nat 1"
}

output "k8s_the_eip_nat2_public_ip" {
  value       =  aws_eip.k8s_the_eip_nat2.public_ip
  description = "Elastic Public IP Nat 2"
}

output "k8s_the_eip_nat1_id" {
  value       =  aws_eip.k8s_the_eip_nat1.id
  description = "Elastic Public ID Nat 1"
}

output "k8s_the_eip_nat2_id" {
  value       =  aws_eip.k8s_the_eip_nat2.id
  description = "Elastic Public ID Nat 2"
}
*/