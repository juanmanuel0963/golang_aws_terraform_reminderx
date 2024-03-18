
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

variable "repository_name"{
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
  repository_name = "k8s_ecr_public_repo_${var.repository_name}"
}
/*
resource "aws_ecrpublic_repository" "the_ecr_public_repo" {

  repository_name = local.repository_name

  catalog_data {
    about_text        = "About ${local.repository_name}"
    description       = "Description ${local.repository_name}"
    usage_text        = "Usage ${local.repository_name}"
  }

}

output "k8s_ecr_public_repo_service_id" {
  value       =  aws_ecrpublic_repository.the_ecr_public_repo.id
  description = "Repository id"
}

output "k8s_ecr_public_repo_service_name" {
  value       =  aws_ecrpublic_repository.the_ecr_public_repo.repository_name
  description = "Repository name"
}

output "k8s_ecr_public_repo_service_uri" {
  value       =  aws_ecrpublic_repository.the_ecr_public_repo.repository_uri
  description = "Repository uri"
}
*/