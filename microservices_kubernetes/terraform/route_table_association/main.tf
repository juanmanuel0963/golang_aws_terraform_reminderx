
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

variable "k8s_the_route_table_public_id"{
  type    = string
}

variable "k8s_the_route_table_private_1_id"{
  type    = string
}

variable "k8s_the_route_table_private_2_id"{
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
  gateway_name = "k8s_route_table_association_${var.random_pet}"
}

# Resource: aws_route_table_association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
/*
resource "aws_route_table_association" "k8s_the_route_table_association_public_1" {
  # The subnet ID to create an association.
  subnet_id = var.k8s_the_subnet_public_1_id

  # The ID of the routing table to associate with.
  route_table_id = var.k8s_the_route_table_public_id
}

resource "aws_route_table_association" "k8s_the_route_table_association_public_2" {
  # The subnet ID to create an association.
  subnet_id = var.k8s_the_subnet_public_2_id

  # The ID of the routing table to associate with.
  route_table_id = var.k8s_the_route_table_public_id
}

resource "aws_route_table_association" "k8s_the_route_table_association_private_1" {
  # The subnet ID to create an association.
  subnet_id = var.k8s_the_subnet_private_1_id

  # The ID of the routing table to associate with.
  route_table_id = var.k8s_the_route_table_private_1_id
}

resource "aws_route_table_association" "k8s_the_route_table_association_private_2" {
  # The subnet ID to create an association.
  subnet_id = var.k8s_the_subnet_private_2_id

  # The ID of the routing table to associate with.
  route_table_id = var.k8s_the_route_table_private_2_id
}

output "k8s_the_route_table_association_public_1_id" {   
  value       = aws_route_table_association.k8s_the_route_table_association_public_1.id
  description = "Route table association public 1 Id"
}

output "k8s_the_route_table_association_public_2_id" {   
  value       = aws_route_table_association.k8s_the_route_table_association_public_2.id
  description = "Route table association public 2 Id"
}

output "k8s_the_route_table_association_private_1_id" {   
  value       = aws_route_table_association.k8s_the_route_table_association_private_1.id
  description = "Route table association private 1 Id"
}
output "k8s_the_route_table_association_private_2_id" {   
  value       = aws_route_table_association.k8s_the_route_table_association_private_2.id
  description = "Route table association private 2 Id"
}
*/