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
# k8s_vpc
##################################################################################

module "module_k8s_vpc" {
  source     = "./microservices_kubernetes/terraform/vpc"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
}

##################################################################################
# vpc - OUTPUT
##################################################################################
/*
output "module_k8s_vpc_the_vpc_id" {
  description = "VPC Id"
  value       = module.module_k8s_vpc.k8s_the_vpc_id
}
*/
##################################################################################
# k8s_internet_gateway
##################################################################################

module "module_k8s_internet_gateway" {
  source     = "./microservices_kubernetes/terraform/internet_gateway"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet

  //k8s_the_vpc_id = module.module_k8s_vpc.k8s_the_vpc_id
}

##################################################################################
# k8s_internet_gateway - OUTPUT
##################################################################################
/*
output "module_k8s_internet_gateway_the_internet_gateway_id" {
  description = "Internet Gateway Id"
  value       = module.module_k8s_internet_gateway.k8s_the_internet_gateway_id
}
*/
##################################################################################
# k8s_subnets
##################################################################################

module "module_k8s_subnets" {
  source     = "./microservices_kubernetes/terraform/subnets"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet

  //k8s_the_vpc_id = module.module_k8s_vpc.k8s_the_vpc_id
}

##################################################################################
# k8s_subnets - OUTPUT
##################################################################################
/*
output "module_k8s_subnets_the_subnet_public_1_id" {
  description = "Subnet public 1 Id"
  value       = module.module_k8s_subnets.k8s_the_subnet_public_1_id
}

output "module_k8s_subnets_the_subnet_public_2_id" {
  description = "Subnet public 2 Id"
  value       = module.module_k8s_subnets.k8s_the_subnet_public_2_id
}

output "module_k8s_subnets_the_subnet_private_1_id" {
  description = "Subnet private 1 Id"
  value       = module.module_k8s_subnets.k8s_the_subnet_private_1_id
}

output "module_k8s_subnets_the_subnet_private_2_id" {
  description = "Subnet private 2 Id"
  value       = module.module_k8s_subnets.k8s_the_subnet_private_2_id
}
*/
##################################################################################
# k8s_eip_nat
##################################################################################

module "module_k8s_eip_nat" {
  source     = "./microservices_kubernetes/terraform/eips"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_vpc_id           = module.module_k8s_vpc.k8s_the_vpc_id
  k8s_the_internet_gateway = module.module_k8s_internet_gateway.k8s_the_internet_gateway_id
*/
}

##################################################################################
# k8s_eip_nat - OUTPUT
##################################################################################
/*
output "module_k8s_eip_nat1_the_public_ip" {
  value       = module.module_k8s_eip_nat.k8s_the_eip_nat1_public_ip
  description = "Elastic Public IP Nat 1"
}

output "module_k8s_eip_nat2_the_public_ip" {
  value       = module.module_k8s_eip_nat.k8s_the_eip_nat2_public_ip
  description = "Elastic Public IP Nat 2"
}

output "module_k8s_eip_nat1_the_id" {
  value       = module.module_k8s_eip_nat.k8s_the_eip_nat1_id
  description = "Elastic Public ID Nat 1"
}

output "module_k8s_eip_nat2_the_id" {
  value       = module.module_k8s_eip_nat.k8s_the_eip_nat2_id
  description = "Elastic Public ID Nat 2"
}
*/
##################################################################################
# k8s_nat_gateways
##################################################################################

module "module_k8s_nat_gateways" {
  source     = "./microservices_kubernetes/terraform/nat_gateways"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_eip_nat1_id        = module.module_k8s_eip_nat.k8s_the_eip_nat1_id
  k8s_the_eip_nat2_id        = module.module_k8s_eip_nat.k8s_the_eip_nat2_id
  k8s_the_subnet_public_1_id = module.module_k8s_subnets.k8s_the_subnet_public_1_id
  k8s_the_subnet_public_2_id = module.module_k8s_subnets.k8s_the_subnet_public_2_id
*/
}

##################################################################################
# k8s_nat_gateways - OUTPUT
##################################################################################
/*
output "module_k8s_nat_gateways_the_nat_gateway_1_id" {
  value       = module.module_k8s_nat_gateways.k8s_the_nat_gateway_1_id
  description = "Nat Gateway 1 Id"
}

output "module_k8s_nat_gateways_the_nat_gateway_2_id" {
  value       = module.module_k8s_nat_gateways.k8s_the_nat_gateway_2_id
  description = "Nat Gateway 2 Id"
}
*/
##################################################################################
# k8s_routing_tables
##################################################################################

module "module_k8s_routing_tables" {
  source     = "./microservices_kubernetes/terraform/routing_tables"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_vpc_id              = module.module_k8s_vpc.k8s_the_vpc_id
  k8s_the_internet_gateway_id = module.module_k8s_internet_gateway.k8s_the_internet_gateway_id
  k8s_the_nat_gateway_1_id    = module.module_k8s_nat_gateways.k8s_the_nat_gateway_1_id
  k8s_the_nat_gateway_2_id    = module.module_k8s_nat_gateways.k8s_the_nat_gateway_2_id
  k8s_the_subnet_public_1_id  = module.module_k8s_subnets.k8s_the_subnet_public_1_id
  k8s_the_subnet_public_2_id  = module.module_k8s_subnets.k8s_the_subnet_public_2_id
*/
}

##################################################################################
# k8s_routing_tables - OUTPUT
##################################################################################
/*
output "module_k8s_routing_tables_the_route_table_public_id" {
  value       = module.module_k8s_routing_tables.k8s_the_route_table_public_id
  description = "Route table public Id"
}

output "module_k8s_routing_tables_the_route_table_private_1_id" {
  value       = module.module_k8s_routing_tables.k8s_the_route_table_private_1_id
  description = "Route table private 1 Id"
}

output "module_k8s_routing_tables_the_route_table_private_2_id" {
  value       = module.module_k8s_routing_tables.k8s_the_route_table_private_2_id
  description = "Route table private 2 Id"
}
*/
##################################################################################
# k8s_route_table_association
##################################################################################

module "module_k8s_route_table_association" {
  source     = "./microservices_kubernetes/terraform/route_table_association"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_vpc_id                = module.module_k8s_vpc.k8s_the_vpc_id
  k8s_the_internet_gateway_id   = module.module_k8s_internet_gateway.k8s_the_internet_gateway_id
  k8s_the_route_table_public_id = module.module_k8s_routing_tables.k8s_the_route_table_public_id

  k8s_the_route_table_private_1_id = module.module_k8s_routing_tables.k8s_the_route_table_private_1_id
  k8s_the_route_table_private_2_id = module.module_k8s_routing_tables.k8s_the_route_table_private_2_id

  k8s_the_subnet_public_1_id = module.module_k8s_subnets.k8s_the_subnet_public_1_id
  k8s_the_subnet_public_2_id = module.module_k8s_subnets.k8s_the_subnet_public_2_id

  k8s_the_subnet_private_1_id = module.module_k8s_subnets.k8s_the_subnet_private_1_id
  k8s_the_subnet_private_2_id = module.module_k8s_subnets.k8s_the_subnet_private_2_id
*/
}

##################################################################################
# k8s_route_table_association - OUTPUT
##################################################################################
/*
output "module_k8s_route_table_association_the_route_table_association_public_1_id" {
  value       = module.module_k8s_route_table_association.k8s_the_route_table_association_public_1_id
  description = "Route table association public 1 Id"
}

output "module_k8s_route_table_association_the_route_table_association_public_2_id" {
  value       = module.module_k8s_route_table_association.k8s_the_route_table_association_public_2_id
  description = "Route table association public 2 Id"
}

output "module_k8s_route_table_association_the_route_table_association_private_1_id" {
  value       = module.module_k8s_route_table_association.k8s_the_route_table_association_private_1_id
  description = "Route table association private 1 Id"
}

output "module_k8s_route_table_association_the_route_table_association_private_2_id" {
  value       = module.module_k8s_route_table_association.k8s_the_route_table_association_private_2_id
  description = "Route table association private 2 Id"
}
*/
##################################################################################
# k8s_eks
##################################################################################

module "module_k8s_eks" {
  source     = "./microservices_kubernetes/terraform/eks"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_vpc_id             = module.module_k8s_vpc.k8s_the_vpc_id
  k8s_the_subnet_public_1_id = module.module_k8s_subnets.k8s_the_subnet_public_1_id
  k8s_the_subnet_public_2_id = module.module_k8s_subnets.k8s_the_subnet_public_2_id

  k8s_the_subnet_private_1_id = module.module_k8s_subnets.k8s_the_subnet_private_1_id
  k8s_the_subnet_private_2_id = module.module_k8s_subnets.k8s_the_subnet_private_2_id
*/
}

##################################################################################
# k8s_eks - OUTPUT
##################################################################################
/*
output "module_k8s_eks_the_eks_iam_role_policy_attachment_id" {
  value       = module.module_k8s_eks.k8s_the_eks_iam_role_policy_attachment_id
  description = "Eks iam role policy attachment Id"
}

output "module_k8s_eks_the_eks_cluster_id" {
  value       = module.module_k8s_eks.k8s_the_eks_cluster_id
  description = "Eks cluster Id"
}

output "module_k8s_eks_the_eks_cluster_name" {
  value       = module.module_k8s_eks.k8s_the_eks_cluster_name
  description = "Eks cluster Name"
}
*/
##################################################################################
# k8s_eks_node_groups
##################################################################################

module "module_k8s_eks_node_groups" {
  source     = "./microservices_kubernetes/terraform/eks_node_groups"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  random_pet = local.random_pet
  /*
  k8s_the_vpc_id           = module.module_k8s_vpc.k8s_the_vpc_id
  k8s_the_eks_cluster_name = module.module_k8s_eks.k8s_the_eks_cluster_name

  k8s_the_subnet_public_1_id  = module.module_k8s_subnets.k8s_the_subnet_public_1_id
  k8s_the_subnet_public_2_id  = module.module_k8s_subnets.k8s_the_subnet_public_2_id
  k8s_the_subnet_private_1_id = module.module_k8s_subnets.k8s_the_subnet_private_1_id
  k8s_the_subnet_private_2_id = module.module_k8s_subnets.k8s_the_subnet_private_2_id
*/
}

##################################################################################
# k8s_eks_node_groups - OUTPUT
##################################################################################
/*
output "module_k8s_the_eks_node_groups_iam_role_id" {
  value       = module.module_k8s_eks_node_groups.k8s_the_eks_node_groups_iam_role_id
  description = "Eks node groups iam role Id"
}

output "module_k8s_the_amazon_ec2_container_registry_read_only_policy_attachment_id" {
  value       = module.module_k8s_eks_node_groups.k8s_the_amazon_ec2_container_registry_read_only_policy_attachment_id
  description = "Amazon ec2 container registry read only policy attachment"
}

output "module_k8s_the_amazon_eks_cni_policy_attachment_id" {
  value       = module.module_k8s_eks_node_groups.k8s_the_amazon_eks_cni_policy_attachment_id
  description = "Amazon eks cni policy attachment"
}

output "module_k8s_the_amazon_eks_worker_node_policy_attachment_id" {
  value       = module.module_k8s_eks_node_groups.k8s_the_amazon_eks_worker_node_policy_attachment_id
  description = "Amazon eks worker node policy attachment"
}

output "module_k8s_the_eks_nodes_group_id" {
  value       = module.module_k8s_eks_node_groups.k8s_the_eks_nodes_group_id
  description = "Eks nodes group Id"
}

*/
##################################################################################
# k8s_ecr_public_repo_ping_service
##################################################################################

module "module_k8s_ecr_public_repo_ping_service" {
  source          = "./microservices_kubernetes/terraform/ecr_public_repository"
  region          = var.region
  access_key      = var.access_key
  secret_key      = var.secret_key
  random_pet      = local.random_pet
  repository_name = "ping"
}

##################################################################################
# k8s_ecr_public_repo_ping_service - OUTPUT
##################################################################################
/*
output "module_k8s_ecr_public_repo_ping_service_id" {
  value       = module.module_k8s_ecr_public_repo_ping_service.k8s_ecr_public_repo_service_id
  description = "Repository id"
}

output "module_k8s_ecr_public_repo_ping_service_name" {
  value       = module.module_k8s_ecr_public_repo_ping_service.k8s_ecr_public_repo_service_name
  description = "Repository name"
}

output "module_k8s_ecr_public_repo_ping_service_uri" {
  value       = module.module_k8s_ecr_public_repo_ping_service.k8s_ecr_public_repo_service_uri
  description = "Repository uri"
}
*/
##################################################################################
# k8s_ecr_public_repo_blogs_service
##################################################################################

module "module_k8s_ecr_public_repo_blogs_service" {
  source          = "./microservices_kubernetes/terraform/ecr_public_repository"
  region          = var.region
  access_key      = var.access_key
  secret_key      = var.secret_key
  random_pet      = local.random_pet
  repository_name = "blogs"
}

##################################################################################
# k8s_ecr_public_repo_blogs_service - OUTPUT
##################################################################################
/*
output "module_k8s_ecr_public_repo_blogs_service_id" {
  value       = module.module_k8s_ecr_public_repo_blogs_service.k8s_ecr_public_repo_service_id
  description = "Repository id"
}

output "module_k8s_ecr_public_repo_blogs_service_name" {
  value       = module.module_k8s_ecr_public_repo_blogs_service.k8s_ecr_public_repo_service_name
  description = "Repository name"
}

output "module_k8s_ecr_public_repo_blogs_service_uri" {
  value       = module.module_k8s_ecr_public_repo_blogs_service.k8s_ecr_public_repo_service_uri
  description = "Repository uri"
}
*/
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
/*
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
*/
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
# contacts_insert
##################################################################################

module "module_contacts_insert" {
  source                           = "./microservices_restful_lambda/contacts_insert/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_insert"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_insert - OUTPUT
##################################################################################

output "module_contacts_insert_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_insert.lambda_func_name
}

output "module_contacts_insert_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_insert.lambda_func_bucket_name
}

output "module_contacts_insert_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_insert.lambda_func_role_name
}

output "module_contacts_insert_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_insert.lambda_func_base_url
}



##################################################################################
# contacts_get_by_contact_id
##################################################################################

module "module_contacts_get_by_contact_id" {
  source                           = "./microservices_restful_lambda/contacts_get_by_contact_id/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_get_by_contact_id"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_get_by_contact_id - OUTPUT
##################################################################################

output "module_contacts_get_by_contact_id_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_get_by_contact_id.lambda_func_name
}

output "module_contacts_get_by_contact_id_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_get_by_contact_id.lambda_func_bucket_name
}

output "module_contacts_get_by_contact_id_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_get_by_contact_id.lambda_func_role_name
}

output "module_contacts_get_by_contact_id_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_get_by_contact_id.lambda_func_base_url
}

##################################################################################
# contacts_get_by_company_id
##################################################################################

module "module_contacts_get_by_company_id" {
  source                           = "./microservices_restful_lambda/contacts_get_by_company_id/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_get_by_company_id"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_get_by_company_id - OUTPUT
##################################################################################

output "module_contacts_get_by_company_id_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_get_by_company_id.lambda_func_name
}

output "module_contacts_get_by_company_id_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_get_by_company_id.lambda_func_bucket_name
}

output "module_contacts_get_by_company_id_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_get_by_company_id.lambda_func_role_name
}

output "module_contacts_get_by_company_id_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_get_by_company_id.lambda_func_base_url
}

##################################################################################
# contacts_update_by_contact_id
##################################################################################

module "module_contacts_update_by_contact_id" {
  source                           = "./microservices_restful_lambda/contacts_update_by_contact_id/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_update_by_contact_id"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_update_by_contact_id - OUTPUT
##################################################################################

output "module_contacts_update_by_contact_id_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_update_by_contact_id.lambda_func_name
}

output "module_contacts_update_by_contact_id_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_update_by_contact_id.lambda_func_bucket_name
}

output "module_contacts_update_by_contact_id_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_update_by_contact_id.lambda_func_role_name
}

output "module_contacts_update_by_contact_id_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_update_by_contact_id.lambda_func_base_url
}

##################################################################################
# contacts_delete_by_contact_id
##################################################################################

module "module_contacts_delete_by_contact_id" {
  source                           = "./microservices_restful_lambda/contacts_delete_by_contact_id/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_delete_by_contact_id"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_delete_by_contact_id - OUTPUT
##################################################################################

output "module_contacts_delete_by_contact_id_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_delete_by_contact_id.lambda_func_name
}

output "module_contacts_delete_by_contact_id_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_delete_by_contact_id.lambda_func_bucket_name
}

output "module_contacts_delete_by_contact_id_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_delete_by_contact_id.lambda_func_role_name
}

output "module_contacts_delete_by_contact_id_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_delete_by_contact_id.lambda_func_base_url
}

##################################################################################
# contacts_get_by_dynamic_filter
##################################################################################

module "module_contacts_get_by_dynamic_filter" {
  source                           = "./microservices_restful_lambda/contacts_get_by_dynamic_filter/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_get_by_dynamic_filter"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_get_by_dynamic_filter - OUTPUT
##################################################################################

output "module_contacts_get_by_dynamic_filter_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_get_by_dynamic_filter.lambda_func_name
}

output "module_contacts_get_by_dynamic_filter_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_get_by_dynamic_filter.lambda_func_bucket_name
}

output "module_contacts_get_by_dynamic_filter_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_get_by_dynamic_filter.lambda_func_role_name
}

output "module_contacts_get_by_dynamic_filter_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_get_by_dynamic_filter.lambda_func_base_url
}

##################################################################################
# contacts_get_by_pagination
##################################################################################

module "module_contacts_get_by_pagination" {
  source                           = "./microservices_restful_lambda/contacts_get_by_pagination/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  lambda_func_name                 = "contacts_get_by_pagination"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  db_subnet_group_name             = module.module_db_postgresql.aws_db_subnet_group_name
}

##################################################################################
# contacts_get_by_pagination - OUTPUT
##################################################################################

output "module_contacts_get_by_pagination_lambda_func_name" {
  description = "Name of the Lambda function."
  value       = module.module_contacts_get_by_pagination.lambda_func_name
}

output "module_contacts_get_by_pagination_lambda_func_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.module_contacts_get_by_pagination.lambda_func_bucket_name
}

output "module_contacts_get_by_pagination_lambda_func_role_name" {
  description = "Name of the rol"
  value       = module.module_contacts_get_by_pagination.lambda_func_role_name
}

output "module_contacts_get_by_pagination_lambda_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_contacts_get_by_pagination.lambda_func_base_url
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

#############################################################################
# VARIABLES - ec2_grpc_server_1 (EC2 instance)
#############################################################################

variable "ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}
variable "grpc_server_1_instance_name" {
  type = string
}
variable "grpc_server_1_tag_name" {
  type = string
}
variable "grpc_server_1_op1_function_name" {
  type = string
}
variable "grpc_server_1_op2_function_name" {
  type = string
}
variable "grpc_server_1_op3_function_name" {
  type = string
}
variable "grpc_server_1_op4_function_name" {
  type = string
}
variable "grpc_server_1_op5_function_name" {
  type = string
}
variable "grpc_server_1_op6_function_name" {
  type = string
}
variable "grpc_server_1_server_install" {
  type = string
}
##################################################################################
# ec2_grpc_server_1 (EC2 instance)
##################################################################################

module "module_ec2_grpc_server_1" {
  //source                            = "./ec2/grpc_server_1/terraform"
  source                      = "./ec2/grpc_instance/terraform"
  instance_name               = var.grpc_server_1_instance_name
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  tag_name                    = var.grpc_server_1_tag_name
  associate_public_ip_address = true
  vpc_id                      = module.module_networking.vpc_id
  security_group_id           = module.module_networking.security_group_id
  random_pet                  = local.random_pet
}

output "module_ec2_grpc_server_1_id" {
  description = "Instance Id"
  value       = module.module_ec2_grpc_server_1.aws_instance_id
}

output "module_ec2_grpc_server_1_name" {
  description = "Instance Name"
  value       = module.module_ec2_grpc_server_1.aws_instance_name
}

output "module_ec2_grpc_server_1_public_ip" {
  description = "Public IP"
  value       = module.module_ec2_grpc_server_1.aws_instance_public_ip
}

output "module_ec2_grpc_server_1_private_ip" {
  description = "Private IP"
  value       = module.module_ec2_grpc_server_1.aws_instance_private_ip
}

##################################################################################
# ec2_grpc_server_1 - eventbridge_server_install - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_server_install" {
  source              = "./microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_server_install/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_server_1_instance_name
  instance_id         = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_server_1_server_install
  random_pet          = local.random_pet
}

output "module_grpc_server_1_server_install" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_server_install.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op1 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op1_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_server/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_server_1_instance_name
  instance_id         = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_server_1_op1_function_name
  random_pet          = local.random_pet
}

output "module_grpc_server_1_op1_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op1_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op2 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op2_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op2_in_memory/eventbridge_server/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_server_1_instance_name
  instance_id         = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_server_1_op2_function_name
  random_pet          = local.random_pet
}

output "module_grpc_server_1_op2_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op2_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op3 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op3_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op3_json_file/eventbridge_server/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_server_1_instance_name
  instance_id         = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_server_1_op3_function_name
  random_pet          = local.random_pet
}

output "module_grpc_server_1_op3_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op3_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op4 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op4_eventbridge_rule" {
  source               = "./microservices_grpc_ec2/usermgmt_op4_db_postgres/eventbridge_server/terraform"
  region               = var.region
  access_key           = var.access_key
  secret_key           = var.secret_key
  instance_name        = var.grpc_server_1_instance_name
  instance_id          = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip  = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name        = var.grpc_server_1_op4_function_name
  random_pet           = local.random_pet
  db_username          = var.db_username
  db_password          = var.db_password
  db_port              = var.db_port
  db_instance_endpoint = module.module_db_postgresql.aws_db_instance_endpoint
  db_instance_address  = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name  = module.module_db_postgresql.aws_db_instance_db_name
}

output "module_grpc_server_1_op4_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op4_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op5 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op5_eventbridge_rule" {
  source               = "./microservices_grpc_ec2/usermgmt_op5_rest_to_grpc/eventbridge_server/terraform"
  region               = var.region
  access_key           = var.access_key
  secret_key           = var.secret_key
  instance_name        = var.grpc_server_1_instance_name
  instance_id          = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip  = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name        = var.grpc_server_1_op5_function_name
  random_pet           = local.random_pet
  db_username          = var.db_username
  db_password          = var.db_password
  db_port              = var.db_port
  db_instance_endpoint = module.module_db_postgresql.aws_db_instance_endpoint
  db_instance_address  = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name  = module.module_db_postgresql.aws_db_instance_db_name
}

output "module_grpc_server_1_op5_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op5_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_server_1 - grpc_usermgmt_op6 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_server_1_op6_eventbridge_rule" {
  source               = "./microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/eventbridge_server/terraform"
  region               = var.region
  access_key           = var.access_key
  secret_key           = var.secret_key
  instance_name        = var.grpc_server_1_instance_name
  instance_id          = module.module_ec2_grpc_server_1.aws_instance_id
  instance_private_ip  = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name        = var.grpc_server_1_op6_function_name
  random_pet           = local.random_pet
  db_username          = var.db_username
  db_password          = var.db_password
  db_port              = var.db_port
  db_instance_endpoint = module.module_db_postgresql.aws_db_instance_endpoint
  db_instance_address  = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name  = module.module_db_postgresql.aws_db_instance_db_name
}

output "module_grpc_server_1_op6_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_server_1_op6_eventbridge_rule.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - ec2_grpc_client_1 (EC2 instance)
#############################################################################

variable "grpc_client_1_instance_name" {
  type = string
}
variable "grpc_client_1_tag_name" {
  type = string
}
variable "grpc_client_1_op1_function_name" {
  type = string
}
variable "grpc_client_1_op2_function_name" {
  type = string
}
variable "grpc_client_1_op3_function_name" {
  type = string
}
variable "grpc_client_1_op4_function_name" {
  type = string
}
variable "grpc_client_1_op5_function_name" {
  type = string
}
variable "grpc_client_1_op6_function_name" {
  type = string
}
variable "grpc_client_1_client_install" {
  type = string
}
##################################################################################
# ec2_grpc_client_1 (EC2 instance)
##################################################################################

module "module_ec2_grpc_client_1" {
  //source                            = "./ec2/grpc_client_1/terraform"
  source                      = "./ec2/grpc_instance/terraform"
  instance_name               = var.grpc_client_1_instance_name
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  tag_name                    = var.grpc_client_1_tag_name
  associate_public_ip_address = true
  vpc_id                      = module.module_networking.vpc_id
  security_group_id           = module.module_networking.security_group_id
  random_pet                  = local.random_pet
}

output "module_ec2_grpc_client_1_id" {
  description = "Instance Id"
  value       = module.module_ec2_grpc_client_1.aws_instance_id
}

output "module_ec2_grpc_client_1_name" {
  description = "Instance Name"
  value       = module.module_ec2_grpc_client_1.aws_instance_name
}

output "module_ec2_grpc_client_1_public_ip" {
  description = "Public IP"
  value       = module.module_ec2_grpc_client_1.aws_instance_public_ip
}

output "module_ec2_grpc_client_1_private_ip" {
  description = "Private IP"
  value       = module.module_ec2_grpc_client_1.aws_instance_private_ip
}

##################################################################################
# ec2_grpc_client_1 - eventbridge_client_install - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_client_install" {
  source              = "./microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_client_1_instance_name
  instance_id         = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_client_1.aws_instance_private_ip
  function_name       = var.grpc_client_1_client_install
  random_pet          = local.random_pet
}

output "module_grpc_client_1_client_install" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_client_install.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op1 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op1_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_client_1_instance_name
  instance_id         = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip   = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_client_1_op1_function_name
  random_pet          = local.random_pet
}

output "module_grpc_client_1_op1_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op1_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op2 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op2_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op2_in_memory/eventbridge_client/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_client_1_instance_name
  instance_id         = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip   = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_client_1_op2_function_name
  random_pet          = local.random_pet
}

output "module_grpc_client_1_op2_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op2_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op3 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op3_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op3_json_file/eventbridge_client/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_client_1_instance_name
  instance_id         = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip   = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_client_1_op3_function_name
  random_pet          = local.random_pet
}

output "module_grpc_client_1_op3_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op3_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op4 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op4_eventbridge_rule" {
  source              = "./microservices_grpc_ec2/usermgmt_op4_db_postgres/eventbridge_client/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.grpc_client_1_instance_name
  instance_id         = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip   = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name       = var.grpc_client_1_op4_function_name
  random_pet          = local.random_pet
}

output "module_grpc_client_1_op4_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op4_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op5 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op5_eventbridge_rule" {
  source                   = "./microservices_grpc_ec2/usermgmt_op5_rest_to_grpc/eventbridge_client/terraform"
  region                   = var.region
  access_key               = var.access_key
  secret_key               = var.secret_key
  instance_name            = var.grpc_client_1_instance_name
  instance_id              = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip      = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip        = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name            = var.grpc_client_1_op5_function_name
  random_pet               = local.random_pet
  aws_cognito_user_pool_id = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_grpc_client_1_op5_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op5_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# ec2_grpc_client_1 - grpc_usermgmt_op6 - (EventBridge rule RunShellScript)
##################################################################################

module "module_grpc_client_1_op6_eventbridge_rule" {
  source                   = "./microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/eventbridge_client/terraform"
  region                   = var.region
  access_key               = var.access_key
  secret_key               = var.secret_key
  instance_name            = var.grpc_client_1_instance_name
  instance_id              = module.module_ec2_grpc_client_1.aws_instance_id
  instance_private_ip      = module.module_ec2_grpc_client_1.aws_instance_private_ip
  server_private_ip        = module.module_ec2_grpc_server_1.aws_instance_private_ip
  function_name            = var.grpc_client_1_op6_function_name
  random_pet               = local.random_pet
  aws_cognito_user_pool_id = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_grpc_client_1_op6_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_grpc_client_1_op6_eventbridge_rule.aws_cloudwatch_event_rule_name
}

##################################################################################
# api_eventb_rule_to_grpc
##################################################################################

module "module_api_eventb_rule_to_grpc" {
  source                           = "./microservices_grpc_ec2/api_eventb_rule_to_grpc/terraform"
  region                           = var.region
  access_key                       = var.access_key
  secret_key                       = var.secret_key
  api_func_name                    = "api_eventb_rule_to_grpc"
  random_integer                   = local.random_integer
  random_pet                       = local.random_pet
  parent_api_gateway_id            = module.module_api_gateway.api_gateway_id
  parent_api_gateway_name          = module.module_api_gateway.api_gateway_name
  parent_api_gateway_execution_arn = module.module_api_gateway.api_gateway_execution_arn
  parent_api_gateway_invoke_url    = module.module_api_gateway.api_gateway_invoke_url
  InstanceConnectionName           = module.module_db_postgresql.aws_db_instance_endpoint
  dbName                           = module.module_db_postgresql.aws_db_instance_db_name
  dbUser                           = var.db_username
  dbPassword                       = var.db_password
  vpc_id                           = module.module_networking.vpc_id
  security_group_id                = module.module_networking.security_group_id
  instance_name                    = var.grpc_client_1_instance_name
  instance_id                      = module.module_ec2_grpc_client_1.aws_instance_id
  server_private_ip                = module.module_ec2_grpc_server_1.aws_instance_private_ip
}

##################################################################################
# api_eventb_rule_to_grpc - OUTPUT
##################################################################################

output "module_api_eventb_rule_to_grpc_api_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value       = module.module_api_eventb_rule_to_grpc.api_func_base_url
}

output "module_api_eventb_rule_to_grpc_api_role_name" {
  description = "Name of the rol"
  value       = module.module_api_eventb_rule_to_grpc.api_func_role_name
}

output "module_api_eventb_rule_to_grpc_eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_api_eventb_rule_to_grpc.aws_cloudwatch_event_rule_name
}


#############################################################################
# VARIABLES - ec2_restful_server_1 (EC2 instance)
#############################################################################

variable "restful_server_1_instance_name" {
  type = string
}
variable "restful_server_1_tag_name" {
  type = string
}
variable "restful_server_1_client_install" {
  type = string
}

##################################################################################
# ec2_restful_server_1 (EC2 instance)
##################################################################################

module "module_ec2_restful_server_1" {
  source                      = "./ec2/grpc_instance/terraform"
  instance_name               = var.restful_server_1_instance_name
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  tag_name                    = var.restful_server_1_tag_name
  associate_public_ip_address = true
  vpc_id                      = module.module_networking.vpc_id
  security_group_id           = module.module_networking.security_group_id
  random_pet                  = local.random_pet
}

output "module_ec2_restful_server_1_id" {
  description = "Instance Id"
  value       = module.module_ec2_restful_server_1.aws_instance_id
}

output "module_ec2_restful_server_1_name" {
  description = "Instance Name"
  value       = module.module_ec2_restful_server_1.aws_instance_name
}

output "module_ec2_restful_server_1_public_ip" {
  description = "Public IP"
  value       = module.module_ec2_restful_server_1.aws_instance_public_ip
}

output "module_ec2_restful_server_1_private_ip" {
  description = "Private IP"
  value       = module.module_ec2_restful_server_1.aws_instance_private_ip
}

##################################################################################
# ec2_restful_server_1 - eventbridge_client_install - (EventBridge rule RunShellScript)
##################################################################################

module "module_restful_server_1_client_install" {
  source              = "./microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.restful_server_1_instance_name
  instance_id         = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name       = var.restful_server_1_client_install
  random_pet          = local.random_pet
}

output "module_restful_server_1_client_install" {
  description = "EventBridge rule name"
  value       = module.module_restful_server_1_client_install.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - microservices_restful_ec2_blogs
#############################################################################

variable "restful_ec2_blogs_install_start" {
  type = string
}

variable "restful_ec2_blogs_port" {
  type = string
}

##################################################################################
# microservices_restful_ec2_blogs - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_blogs_install_start" {
  source                   = "./microservices_restful_ec2/blogs/terraform"
  region                   = var.region
  access_key               = var.access_key
  secret_key               = var.secret_key
  instance_name            = var.restful_server_1_instance_name
  instance_id              = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip      = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name            = var.restful_ec2_blogs_install_start
  random_pet               = local.random_pet
  db_password              = var.db_password
  db_instance_address      = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name      = module.module_db_postgresql.aws_db_instance_db_name
  db_port                  = var.db_port
  blogs_port               = var.restful_ec2_blogs_port
  aws_cognito_user_pool_id = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_microservices_restful_ec2_blogs_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_blogs_install_start.aws_cloudwatch_event_rule_name
}


#############################################################################
# VARIABLES - microservices_restful_ec2_posts
#############################################################################

variable "restful_ec2_posts_install_start" {
  type = string
}

variable "restful_ec2_posts_port" {
  type = string
}

##################################################################################
# microservices_restful_ec2_posts - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_posts_install_start" {
  source              = "./microservices_restful_ec2/posts/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.restful_server_1_instance_name
  instance_id         = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name       = var.restful_ec2_posts_install_start
  random_pet          = local.random_pet
  db_password         = var.db_password
  db_instance_address = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name = module.module_db_postgresql.aws_db_instance_db_name
  db_port             = var.db_port
  posts_port          = var.restful_ec2_posts_port
}

output "module_microservices_restful_ec2_posts_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_posts_install_start.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - microservices_restful_ec2_invoices
#############################################################################

variable "restful_ec2_invoices_install_start" {
  type = string
}

variable "restful_ec2_invoices_port" {
  type = string
}

################################################################################## 
# microservices_restful_ec2_invoices - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_invoices_install_start" {
  source              = "./microservices_restful_ec2/invoices/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.restful_server_1_instance_name
  instance_id         = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name       = var.restful_ec2_invoices_install_start
  random_pet          = local.random_pet
  db_password         = var.db_password
  db_instance_address = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name = module.module_db_postgresql.aws_db_instance_db_name
  db_port             = var.db_port
  invoices_port       = var.restful_ec2_invoices_port
}

output "module_microservices_restful_ec2_invoices_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_invoices_install_start.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - microservices_restful_ec2_products
#############################################################################

variable "restful_ec2_products_install_start" {
  type = string
}

variable "restful_ec2_products_port" {
  type = string
}

##################################################################################
# microservices_restful_ec2_products - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_products_install_start" {
  source              = "./microservices_restful_ec2/products/terraform"
  region              = var.region
  access_key          = var.access_key
  secret_key          = var.secret_key
  instance_name       = var.restful_server_1_instance_name
  instance_id         = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name       = var.restful_ec2_products_install_start
  random_pet          = local.random_pet
  db_password         = var.db_password
  db_instance_address = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name = module.module_db_postgresql.aws_db_instance_db_name
  db_port             = var.db_port
  products_port       = var.restful_ec2_products_port
}

output "module_microservices_restful_ec2_products_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_products_install_start.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - microservices_restful_ec2_users
#############################################################################

variable "restful_ec2_users_install_start" {
  type = string
}

variable "restful_ec2_users_port" {
  type = string
}

##################################################################################
# microservices_restful_ec2_users - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_users_install_start" {
  source                   = "./microservices_restful_ec2/users/terraform"
  region                   = var.region
  access_key               = var.access_key
  secret_key               = var.secret_key
  instance_name            = var.restful_server_1_instance_name
  instance_id              = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip      = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name            = var.restful_ec2_users_install_start
  random_pet               = local.random_pet
  db_password              = var.db_password
  db_instance_address      = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name      = module.module_db_postgresql.aws_db_instance_db_name
  db_port                  = var.db_port
  users_port               = var.restful_ec2_users_port
  aws_cognito_user_pool_id = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_microservices_restful_ec2_users_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_users_install_start.aws_cloudwatch_event_rule_name
}


#############################################################################
# VARIABLES - microservices_restful_ec2_cars
#############################################################################

variable "restful_ec2_cars_install_start" {
  type = string
}

variable "restful_ec2_cars_port" {
  type = string
}

##################################################################################
# microservices_restful_ec2_cars - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_cars_install_start" {
  source                   = "./microservices_restful_ec2/cars/terraform"
  region                   = var.region
  access_key               = var.access_key
  secret_key               = var.secret_key
  instance_name            = var.restful_server_1_instance_name
  instance_id              = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip      = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name            = var.restful_ec2_cars_install_start
  random_pet               = local.random_pet
  db_password              = var.db_password
  db_instance_address      = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name      = module.module_db_postgresql.aws_db_instance_db_name
  db_port                  = var.db_port
  cars_port                = var.restful_ec2_cars_port
  aws_cognito_user_pool_id = module.module_aws_cognito_user_pool.aws_cognito_user_pool_id
}

output "module_microservices_restful_ec2_cars_install_start_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_cars_install_start.aws_cloudwatch_event_rule_name
}

#############################################################################
# VARIABLES - microservices_restful_ec2_database_migrate
#############################################################################

variable "restful_ec2_database_migrate" {
  type = string
}

##################################################################################
# microservices_restful_ec2_database_migrate - eventbridge_install_start - (EventBridge rule RunShellScript)
##################################################################################

module "module_microservices_restful_ec2_database_migrate" {
  source               = "./microservices_restful_ec2/_database/terraform"
  region               = var.region
  access_key           = var.access_key
  secret_key           = var.secret_key
  instance_name        = var.restful_server_1_instance_name
  instance_id          = module.module_ec2_restful_server_1.aws_instance_id
  instance_private_ip  = module.module_ec2_restful_server_1.aws_instance_private_ip
  function_name        = var.restful_ec2_database_migrate
  random_pet           = local.random_pet
  db_username          = var.db_username
  db_password          = var.db_password
  db_port              = var.db_port
  db_instance_endpoint = module.module_db_postgresql.aws_db_instance_endpoint
  db_instance_address  = module.module_db_postgresql.aws_db_instance_address
  db_instance_db_name  = module.module_db_postgresql.aws_db_instance_db_name
}

output "module_microservices_restful_ec2_database_migrate_rule_name" {
  description = "EventBridge rule name"
  value       = module.module_microservices_restful_ec2_database_migrate.aws_cloudwatch_event_rule_name
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

