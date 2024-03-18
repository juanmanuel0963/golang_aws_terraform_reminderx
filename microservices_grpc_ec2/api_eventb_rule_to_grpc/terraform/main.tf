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

variable "api_func_name" {
  type    = string
}

variable "random_integer"{
  type    = string
}

variable "random_pet"{
  type    = string
}

variable "parent_api_gateway_id"{
  type    = string
}

variable "parent_api_gateway_name"{
  type    = string
}

variable "parent_api_gateway_execution_arn"{
  type    = string
}

variable "parent_api_gateway_invoke_url"{
  type    = string
}

variable "InstanceConnectionName"{
  type    = string
}

variable "dbName"{
  type    = string
}

variable "dbUser"{
  type    = string
}

variable "dbPassword"{
  type    = string
}

variable "vpc_id"{
  type    = string
}

variable "security_group_id"{
  type    = string
}

variable "instance_name" {
  type    = string
}

variable "instance_id" {
  type    = string
}

variable "server_private_ip" {
  type    = string
}

locals {
  //default_aws_db_subnet_group = "default-${var.vpc_id}"  
  //default_aws_db_subnet_group_name  = "${var.vpc_id}_subnet_group_${var.random_pet}"
  //api_func_name           = "${var.api_func_name}_${replace("${var.random_pet}", "-", "_")}"
  api_func_name           = "${var.api_func_name}"
  api_func_role_name      = "${var.api_func_name}_api_gateway_role_${var.random_pet}"
  eventbridge_role_name   = "${var.api_func_name}_eventbridge_role_${var.random_pet}"
  rule_name               = "${var.instance_name}_${var.api_func_name}_rule_${var.random_pet}"
  target_name             = "${var.instance_name}_${var.api_func_name}_target_${var.random_pet}"
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
# MODULES
#############################################################################  


#############################################################################
# API Gateway
#############################################################################  

//----------db_subnet_group lookup----------
/*
data "aws_db_subnet_group" "the_db_subnet_group" {
  name = "${local.default_aws_db_subnet_group_name}"
}
*/
//----------IAM Rol creation----------


//Defines an IAM role that allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "the_apigateway_role" {
  name = "${local.api_func_role_name}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      }
    ]
  })
}

//----------Policy assignment to the IAM Rol----------

//Attaches a policy to the IAM role.
//AmazonAPIGatewayPushToCloudWatchLogs Allows API Gateway to push logs to user's account.
resource "aws_iam_role_policy_attachment" "api_gateway_access_execution_role" {
  role       = aws_iam_role.the_apigateway_role.name  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

//Attaches a policy to the IAM role.
//AmazonEventBridgeFullAccess Provides full access to Amazon EventBridge.
resource "aws_iam_role_policy_attachment" "eventbridge_access_execution_role" {
  role       = aws_iam_role.the_apigateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

//----------API Gateway - adding the EventBridge (Integrations part) ----------

//Configures the API Gateway to use your Lambda function.
resource "aws_apigatewayv2_integration" "the_api_function" {
  api_id = var.parent_api_gateway_id

  credentials_arn     = aws_iam_role.the_apigateway_role.arn
  description         = "API Gateway / Eventbridge integration"
  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"

  request_parameters  = {
    "Detail"          = "$request.body.detail"
    "DetailType"      = "sampledata"
    "Source"          = "com.srcecde.app"
  }
}

//----------API Gateway - adding the EventBridge (Routes part) ----------

//Maps an HTTP request to a target, in this case your Lambda function. 
//In the example configuration, the route_key matches any GET request matching the path /hello. 
//A target matching integrations/<ID> maps to a Lambda integration with the given ID.
resource "aws_apigatewayv2_route" "the_api_function" {
  api_id = var.parent_api_gateway_id

  route_key = "ANY /${local.api_func_name}"  
  target    = "integrations/${aws_apigatewayv2_integration.the_api_function.id}"
  //authorization_type = "AWS_IAM"
}

##################################################################################
# OUTPUT
##################################################################################

output "api_func_base_url" {
  description = "Base URL for API Gateway stage + function name"
  value = "${var.parent_api_gateway_invoke_url}${local.api_func_name}"  
}

output "api_func_role_name" {
  description = "Name of the rol"
  value = aws_iam_role.the_apigateway_role.name
}

#############################################################################
# EventBridge
#############################################################################  

//----------IAM Rol creation----------

//Defines an IAM role that allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "the_eventbridge_role" {  
  name = "${local.eventbridge_role_name}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })

}

//----------Policy assignment to the IAM Rol----------

//Attaches a policy to the IAM role.
//AmazonSSMFullAccess Provides full access to Amazon SSM.
resource "aws_iam_role_policy_attachment" "ssm_access_execution_role" {
  role        = aws_iam_role.the_eventbridge_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

#-----Cloudwatch Rule--------

resource "aws_cloudwatch_event_rule" "the_rule" {
  name                = "${local.rule_name}"
  description         = "${local.rule_name}"
  event_pattern       =   "{\"source\": [\"com.srcecde.app\"], \"detail-type\": [\"sampledata\"], \"detail\": {\"name\": [\"trigger_usermgmt_op4_db_postgres\"]}}"
}
#-----Cloudwatch Target--------

resource "aws_cloudwatch_event_target" "the_target" {
  target_id                = "${local.target_name}"
  arn       = "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
  
  input     = "{\"commands\":[\"export server_address=${var.server_private_ip}\",\"export HOME=/home/ubuntu\",\"export GOPATH=$HOME/go\",\"export GOMODCACHE=$HOME/go/pkg/mod\",\"export GOCACHE=$HOME/.cache/go-build\",\"cd /home/ubuntu/\",\"cd golang_aws_terraform_jenkins\",\"cd microservices_grpc_ec2/usermgmt_op4_db_postgres/usermgmt_client\",\"sudo chmod 700 usermgmt_client\",\"sudo --preserve-env ./usermgmt_client\"]}"
  rule      = aws_cloudwatch_event_rule.the_rule.name
  role_arn  = aws_iam_role.the_eventbridge_role.arn

  run_command_targets {
    key    = "InstanceIds"
    values = ["${var.instance_id}"]
  }
}

##################################################################################
# EventBridge - OUTPUT
##################################################################################

output "aws_cloudwatch_event_rule_name" {
  description = "EventBridge rule name"
  value = aws_cloudwatch_event_rule.the_rule.name
}
