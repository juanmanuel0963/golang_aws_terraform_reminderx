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

variable "instance_name" {
  type    = string
}

variable "instance_id" {
  type    = string
}

variable "instance_private_ip" {
  type    = string
}

variable "function_name" {
  type    = string
}

variable "random_pet"{
  type    = string
}

locals {
  availability_zone = "${var.region}c"  
  rule_name               = "${var.instance_name}_${var.function_name}_rule_${var.random_pet}"
  iam_role_name           = "${var.instance_name}_${var.function_name}_iam_role_${var.random_pet}"
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
# RESOURCES
#############################################################################  

//----------IAM Rol creation----------

//Defines an IAM role that allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "the_iam_role" {
  //name = "${var.instance_name}_${var.function_name}_iam_role"
  name = local.iam_role_name
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
//AmazonEC2FullAccess Provides full access to Amazon EC2 via the AWS Management Console.
resource "aws_iam_role_policy_attachment" "aws_ec2_access_execution_role" {
  role        = aws_iam_role.the_iam_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

//Attaches a policy to the IAM role.
//AmazonEC2FullAccess Provides full access to Amazon EC2 via the AWS Management Console.
resource "aws_iam_role_policy_attachment" "the_execution_role" {
  role        = aws_iam_role.the_iam_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

//Attaches a policy to the IAM role.
//AmazonSSMFullAccess Provides full access to Amazon SSM.
resource "aws_iam_role_policy_attachment" "aws_cloudwatch_access_execution_role" {
  role        = aws_iam_role.the_iam_role.name
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

//Attaches a policy to the IAM role.
//AmazonSSMManagedInstanceCore The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.
resource "aws_iam_role_policy_attachment" "aws_ssm_managed_execution_role" {
  role        = aws_iam_role.the_iam_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#-----Cloudwatch Rule--------

resource "aws_cloudwatch_event_rule" "the_rule" {
  name                = "${local.rule_name}"
  description         = "${local.rule_name}"
  schedule_expression = "cron(0/10 * * * ? *)" //every 10 minutes
}

#-----Cloudwatch Target--------

resource "aws_cloudwatch_event_target" "the_target" {
  target_id = "${var.instance_name}_${var.function_name}_target"
  arn       = "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
  //input     = "{\"commands\":[\"ls -a\"]}"
  //input     = "{\"commands\":[\"sudo shutdown -r now\"]}"
  input     = "{\"commands\":[\"sudo snap install go --classic\",\"cd /home/ubuntu/\",\"sudo rm -rf golang_aws_terraform_jenkins\",\"git clone https://github.com/juanmanuel0963/golang_aws_terraform_jenkins.git\",\"export HOME=/home/ubuntu\",\"export GOROOT=/snap/go/current\",\"export GOPATH=$HOME/snap/go/current\",\"export GOMODCACHE=$GOPATH/pkg/mod\",\"export GOBIN=$GOPATH/bin\",\"mkdir tls\",\"sudo chmod 777 ./tls\",\"cd /home/ubuntu/tls\",\"go run $GOROOT/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost\"]}" //,\"sudo shutdown -r now\"
  //input     = "{\"commands\":[\"sudo snap install go --classic\",\"cd /home/ubuntu/\",\"sudo rm -rf golang_aws_terraform_jenkins\",\"git clone https://github.com/juanmanuel0963/golang_aws_terraform_jenkins.git\",\"export HOME=/home/ubuntu\",\"export GOROOT=/snap/go/current\",\"export GOPATH=$HOME/snap/go/current\",\"export GOMODCACHE=$GOPATH/pkg/mod\",\"export GOBIN=$GOPATH/bin\",\"mkdir tls\",\"sudo chmod 777 ./tls\",\"cd /home/ubuntu/tls\",\"go run $GOROOT/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost\",\"cd /home/ubuntu/\",\"export GOROOT=/snap/go/10073\",\"export GOPATH=$HOME/snap/go/10073\",\"export GOMODCACHE=$GOPATH/pkg/mod\",\"export GOBIN=$GOPATH/bin\",\"mkdir tls\",\"sudo chmod 777 ./tls\",\"cd /home/ubuntu/tls\",\"go run $GOROOT/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost\",\"cd /home/ubuntu/\",\"export GOROOT=/snap/go/10164\",\"export GOPATH=$HOME/snap/go/10164\",\"export GOMODCACHE=$GOPATH/pkg/mod\",\"export GOBIN=$GOPATH/bin\",\"mkdir tls\",\"sudo chmod 777 ./tls\",\"cd /home/ubuntu/tls\",\"go run $GOROOT/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost\"]}" //,\"sudo shutdown -r now\"
  
  rule      = aws_cloudwatch_event_rule.the_rule.name
  role_arn  = aws_iam_role.the_iam_role.arn

  run_command_targets {
    key    = "InstanceIds"
    values = ["${var.instance_id}"]
  }
}

##################################################################################
# aws_cloudwatch_event_rule - OUTPUT
##################################################################################

output "aws_cloudwatch_event_rule_name" {
  description = "EventBridge rule name"
  value = aws_cloudwatch_event_rule.the_rule.name
}
