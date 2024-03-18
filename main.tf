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

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

resource "random_pet" "api_gateway" {
  length = 1
}

locals {
  random_integer = random_integer.rand.result
  random_pet     = replace("${random_pet.api_gateway.id}", "-", "_")
}

##################################################################################
# networking
##################################################################################

module "module_networking" {
  source              = "./networking/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  security_group_name = "sg_${local.random_pet}"

  //k8s_eip_nat2_the_public_ip = module.module_k8s_eip_nat.k8s_the_eip_nat2_public_ip
}

##################################################################################
# networking - OUTPUT
##################################################################################

output "module_networking_security_group" {
  description = "Security Group"
  value       = module.module_networking.security_group
}

output "module_networking_security_group_name" {
  description = "Security Group Name"
  value       = module.module_networking.security_group_name
}

output "module_networking_security_group_id" {
  description = "Security Group Id"
  value       = module.module_networking.security_group_id
}

output "module_networking_security_group_vpc_id" {
  description = "Security Group Vpc Id"
  value       = module.module_networking.security_group_vpc_id
}

output "module_networking_vpc_id" {
  description = "Vpc Id"
  value       = module.module_networking.vpc_id
}

output "module_networking_local_home_ip_address" {
  description = "Local Home Ip Address"
  value       = module.module_networking.local_home_ip_address
}

##################################################################################
# api_gateway
##################################################################################

module "module_api_gateway" {
  source           = "./api_gateway/terraform"
  region           = var.region
  access_key       = var.access_key
  secret_key       = var.secret_key
  api_gateway_name = "api_gateway_${local.random_pet}"
}

##################################################################################
# api_gateway - OUTPUT
##################################################################################

output "module_api_gateway_id" {
  description = "Id of the API Gateway."
  value       = module.module_api_gateway.api_gateway_id
}

output "module_api_gateway_name" {
  description = "Name of the API Gateway."
  value       = module.module_api_gateway.api_gateway_name
}

output "module_api_gateway_execution_arn" {
  description = "Execution arn of the API Gateway."
  value       = module.module_api_gateway.api_gateway_execution_arn
}

output "module_api_gateway_invoke_url" {
  description = "Base URL for API Gateway stage."
  value       = module.module_api_gateway.api_gateway_invoke_url
}


#############################################################################
# VARIABLES - db_postgresql
#############################################################################

variable "identifier" {
  type = string
}

variable "storage_type" {
  type = string
}

variable "allocated_storage" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_port" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "publicly_accessible" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "backup_retention_period" {
  type = string
}

variable "backup_window" {
  type = string
}

variable "maintenance_window" {
  type = string
}

variable "apply_immediately" {
  type = bool
}

##################################################################################
# db_postgresql
##################################################################################

module "module_db_postgresql" {
  source                  = "./db_postgresql/terraform"
  region                  = var.region
  access_key              = var.access_key
  secret_key              = var.secret_key
  identifier              = var.identifier
  storage_type            = var.storage_type
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_port                 = var.db_port
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  parameter_group_name    = var.parameter_group_name
  publicly_accessible     = var.publicly_accessible
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  random_pet              = local.random_pet
  vpc_id                  = module.module_networking.vpc_id
  security_group_id       = module.module_networking.security_group_id
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  apply_immediately       = var.apply_immediately
}

##################################################################################
# db_postgresql - OUTPUT
##################################################################################

output "module_db_postgresql_aws_db_instance_identifier" {
  description = "Server Name"
  value       = module.module_db_postgresql.aws_db_instance_identifier
}

output "module_db_postgresql_aws_db_instance_db_name" {
  description = "DB Name"
  value       = module.module_db_postgresql.aws_db_instance_db_name
}

output "module_db_postgresql_aws_db_instance_vpc_security_group_ids" {
  description = "Security Group"
  value       = module.module_db_postgresql.aws_db_instance_vpc_security_group_ids
}

output "module_db_postgresql_aws_db_instance_db_subnet_group_name" {
  description = "Subnet Group"
  value       = module.module_db_postgresql.aws_db_instance_db_subnet_group_name
}

output "module_db_postgresql_aws_db_instance_endpoint" {
  description = "Endpoint"
  value       = module.module_db_postgresql.aws_db_instance_endpoint
}

output "module_db_postgresql_aws_db_instance_address" {
  description = "Address"
  value       = module.module_db_postgresql.aws_db_instance_address
}

output "module_db_postgresql_aws_db_subnet_group_name" {
  description = "DB Subnet Group Name"
  value       = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# lambda_func_node
##################################################################################

module "module_lambda_func_node" {
  source                           = "./microservices_restful_lambda/lambda_func_node/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "lambda_func_node"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
}

##################################################################################
# lambda_func_node - OUTPUT
##################################################################################

output "module_lambda_func_node_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_lambda_func_node.lambda_func_name
}

output "module_lambda_func_node_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_lambda_func_node.lambda_func_bucket_name
}

output "module_lambda_func_node_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_lambda_func_node.lambda_func_role_name
}

output "module_lambda_func_node_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_lambda_func_node.lambda_func_base_url
}

##################################################################################
# lambda_func_go
##################################################################################

module "module_lambda_func_go" {
  source                           = "./microservices_restful_lambda/lambda_func_go/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "lambda_func_go"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
}

##################################################################################
# lambda_func_go - OUTPUT
##################################################################################

output "module_lambda_func_go_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_lambda_func_go.lambda_func_name
}

output "module_lambda_func_go_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_lambda_func_go.lambda_func_bucket_name
}

output "module_lambda_func_go_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_lambda_func_go.lambda_func_role_name
}

output "module_lambda_func_go_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_lambda_func_go.lambda_func_base_url
}

##################################################################################
# reminderx_admins
##################################################################################

module "module_reminderx_admins" {
  source                           = "./microservices_lambda_reminderx/rmdx_admins/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "rmdx_admins"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  dbInstanceAddress                = module.module_db_postgresql.aws_db_instance_address
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  dbPort                           = var.db_port
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# reminderx_admins - OUTPUT
##################################################################################

output "module_reminderx_admins_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_reminderx_admins.lambda_func_name
}

output "module_reminderx_admins_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_reminderx_admins.lambda_func_bucket_name
}

output "module_reminderx_admins_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_reminderx_admins.lambda_func_role_name
}

output "module_reminderx_admins_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_reminderx_admins.lambda_func_base_url
}

##################################################################################
# aws_cognito_user_pool
##################################################################################

module "module_aws_cognito_user_pool" {
  source     = "./cognito/auth_token/terraform"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  username   = var.db_username
  password   = var.db_password
}

##################################################################################
# aws_cognito_user_pool - OUTPUT
##################################################################################

output "module_aws_cognito_user_pool_id" {
  description = "Cognito User pool ID"
  value       = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_aws_cognito_user_pool_name" {
  description = "Cognito User pool name"
  value       = module.module_aws_cognito_user_pool.aws_cognito_user_pool_name
}


output "module_aws_cognito_user_pool_app_client_id" {
  description = "Cognito client app ID"
  value       = module.module_aws_cognito_user_pool.aws_cognito_user_pool_app_client_id
}

output "module_aws_cognito_user_pool_app_client_name" {
  description = "Cognito client app name"
  value       = module.module_aws_cognito_user_pool.aws_cognito_user_pool_app_client_name
}

