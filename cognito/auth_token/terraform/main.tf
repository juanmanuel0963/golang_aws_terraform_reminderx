#############################################################################
# VARIABLES
#############################################################################

variable "region" {
  type    = string
}

variable "access_key" {
  type    = string
}

variable "secret_key" {
  type    = string
}


variable "random_pet"{
  type    = string
}

variable "username"{
  type    = string
}

variable "password"{
  type    = string
}

locals {
  availability_zone       = "${var.region}c"
  user_pool_name   = "user_pool_${var.random_pet}"
  app_client_name   = "app_client_${var.random_pet}"
  resource_server_name   = "resource_server_name_${var.random_pet}"
  resource_server_id   = "resource_server_id_${var.random_pet}"
  domain = replace("user-pool-${var.random_pet}","_","-")
  //domain = replace("${aws_cognito_user_pool.the_pool.id}","_","-")
  //domain       = "https://juanmadiaznet123.auth.${var.region}.amazoncognito.com"
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

#############################################################################
# RESOURCES
#############################################################################  

//----------Cognito User Pool creation----------
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool
//Provides a Cognito User Pool resource.
resource "aws_cognito_user_pool" "the_pool" {
  name = local.user_pool_name

  admin_create_user_config{
    allow_admin_create_user_only = true
  }

  //alias_attributes = ["email"]
  //auto_verified_attributes = ["email"]

  deletion_protection = "ACTIVE"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }  
}


//----------App Client creation----------
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client

resource "aws_cognito_user_pool_client" "the_app_client" {
  name = local.app_client_name
  user_pool_id = "${aws_cognito_user_pool.the_pool.id}"
  generate_secret     = true
  callback_urls       = ["https://oauth.pstmn.io/v1/browser-callback"]
    
  //write_attributes = ["test/write"]
  //read_attributes  = ["test/read"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid","phone",]
  supported_identity_providers         = ["COGNITO"]
  //allowed_oauth_scopes                 = ["${aws_cognito_resource_server.the_resource_server.scope_identifiers}"]
}

//----------Resource Server----------
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server

resource "aws_cognito_resource_server" "the_resource_server" {
  identifier = local.resource_server_id
  name       = local.resource_server_name
  user_pool_id = "${aws_cognito_user_pool.the_pool.id}"

  scope {
    scope_name        = "read"
    scope_description = "for GET"
  }

  scope {
    scope_name        = "write"
    scope_description = "for POST"
  }
}

//----------User----------
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user

resource "aws_cognito_user" "the_user" {
  user_pool_id = "${aws_cognito_user_pool.the_pool.id}"
  username = var.username
  password = var.password
  attributes = {
    email          = "juanmadiaz.net@gmail.com"
    email_verified = true
  }
  enabled = true
}

//----------Domain----------
//Provides a Cognito User Pool Domain resource.
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain
resource "aws_cognito_user_pool_domain" "the_domain" {  
  user_pool_id = "${aws_cognito_user_pool.the_pool.id}"
  domain = local.domain
}



##################################################################################
# aws_cognito_user_pool - OUTPUT
##################################################################################

output "aws_cognito_user_pool_id" {
  description = "Cognito User pool ID"
  value = aws_cognito_user_pool.the_pool.id
}

output "aws_cognito_user_pool_name" {
  description = "Cognito User pool name"
  value = aws_cognito_user_pool.the_pool.name
}

output "aws_cognito_user_pool_app_client_id" {
  description = "Cognito client app ID"
  value = aws_cognito_user_pool_client.the_app_client.id
}

output "aws_cognito_user_pool_app_client_name" {
  description = "Cognito client app name"
  value = aws_cognito_user_pool_client.the_app_client.name
}

output "aws_cognito_resource_server_name" {
  description = "Resource server name"
  value = aws_cognito_resource_server.the_resource_server.name
}

output "aws_cognito_resource_server_identifier" {
  description = "Resource server identifier"
  value = aws_cognito_resource_server.the_resource_server.identifier
}