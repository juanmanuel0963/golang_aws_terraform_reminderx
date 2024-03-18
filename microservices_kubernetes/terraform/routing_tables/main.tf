
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

variable "k8s_the_internet_gateway_id"{
  type    = string
}

variable "k8s_the_nat_gateway_1_id"{
  type    = string
}

variable "k8s_the_nat_gateway_2_id"{
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
  gateway_name = "k8s_routing_tables_${var.random_pet}"
}

# Resource: aws_route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
/*
resource "aws_route_table" "k8s_the_route_table_public" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC internet gateway or a virtual private gateway.
    gateway_id = var.k8s_the_internet_gateway_id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "Route Table Public"
  }
}

resource "aws_route_table" "k8s_the_route_table_private_1" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.
    nat_gateway_id = var.k8s_the_nat_gateway_1_id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "Route Table Private 1"
  }
}

resource "aws_route_table" "k8s_the_route_table_private_2" {
  # The VPC ID.
  vpc_id = var.k8s_the_vpc_id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.
    nat_gateway_id = var.k8s_the_nat_gateway_2_id
  }

  # A map of tags to assign to the resource.
  tags = {
     Name = "Route Table Private 2"
  }
}

output "k8s_the_route_table_public_id" {  
  description = "Route table public Id"
  value       = aws_route_table.k8s_the_route_table_public.id
}

output "k8s_the_route_table_private_1_id" {  
  description = "Route table private 1 Id"
  value       = aws_route_table.k8s_the_route_table_private_1.id
}

output "k8s_the_route_table_private_2_id" {  
  description = "Route table private 2 Id"
  value       = aws_route_table.k8s_the_route_table_private_2.id
}
*/