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

variable "identifier" {
  type    = string
}

variable "storage_type" {
  type    = string
}

variable "allocated_storage" {
  type    = string
}

variable "engine" {
  type    = string
}

variable "engine_version" {
  type    = string
}

variable "instance_class" {
  type    = string
}

variable "db_port" {
  type    = string
}

variable "db_name" {
  type    = string
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type    = string
}

variable "parameter_group_name" {
  type    = string
}

variable "publicly_accessible" {
  type    = bool
}

variable "deletion_protection" {
  type    = bool
}

variable "skip_final_snapshot" {
  type    = bool
}

variable "random_pet"{
  type    = string
}

variable "vpc_id"{
  type    = string
}

variable "security_group_id"{
  type    = string
}

variable "backup_retention_period"{
  type    = string
}

variable "backup_window"{
  type    = string
}

variable "maintenance_window"{
  type    = string
}

variable apply_immediately{
  type    = bool 
}

locals {
  //default_aws_db_subnet_group       = "default-${var.vpc_id}"
  default_aws_db_subnet_group_name  = "${var.vpc_id}_subnet_group_${var.random_pet}"
  identifier = "${var.identifier}-${replace("${var.random_pet}", "_", "-")}" 
  db_name    = "${var.db_name}_${var.random_pet}" 
  availability_zone = "${var.region}c"  
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

//----------Sets the default vpc----------

resource "aws_default_vpc" "default_vpc" { }

data "aws_subnets" "default_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default_vpc.id]
  }
}

//----------db_security_group lookup----------
/*
data "aws_security_groups" "the_db_security_group" {
  
  filter {
    name   = "group-name"
    values = ["db_security_group"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
    //values = [aws_default_vpc.default.id]
  }
}
*/

resource "aws_db_subnet_group" "the_db_subnet_group" {
  name       = local.default_aws_db_subnet_group_name
  subnet_ids = data.aws_subnets.default_subnet_ids.ids
}

//----------Creates the AWS db instance----------

resource "aws_db_instance" "the_postgresql_instance" {
  identifier              = local.identifier
  storage_type            = var.storage_type
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  port                    = var.db_port
  
  vpc_security_group_ids  = [var.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.the_db_subnet_group.id

  db_name                 = local.db_name
  username                = var.db_username
  password                = var.db_password
  
  parameter_group_name    = var.parameter_group_name
  availability_zone       = local.availability_zone

  publicly_accessible     = var.publicly_accessible
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  apply_immediately       = var.apply_immediately
}

##################################################################################
# aws_db_instance - OUTPUT
##################################################################################

output "aws_db_instance_identifier" {
  description = "Server Name"
  value = aws_db_instance.the_postgresql_instance.identifier
}

output "aws_db_instance_db_name" {
  description = "DB Name"
  value = aws_db_instance.the_postgresql_instance.db_name
}

output "aws_db_instance_vpc_security_group_ids" {
  description = "Security Group"
  value = aws_db_instance.the_postgresql_instance.vpc_security_group_ids
}

output "aws_db_instance_db_subnet_group_name" {
  description = "Subnet Group"
  value = aws_db_instance.the_postgresql_instance.db_subnet_group_name
}

output "aws_db_instance_endpoint" {
  description = "Endpoint"
  value = aws_db_instance.the_postgresql_instance.endpoint
}

output "aws_db_instance_address" {
  description = "Address"
  value = aws_db_instance.the_postgresql_instance.address
}

output "aws_db_subnet_group_name" {
  description = "DB Subnet Group Name"
  value = aws_db_instance.the_postgresql_instance.db_subnet_group_name
}
