
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

variable "ami_id" {
  description = "AMI for Ubuntu Ec2 instance"
  type    = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type    = string
}

variable "key_name" {
  description = "SSH keys to connect to EC2 instance"
  type    = string
}

variable "instance_name" {
  description = "Name for this EC2 instance"
  type    = string
}

variable "tag_name" {
  description = "Tag name for this EC2 instance"
  type    = string
}

variable "associate_public_ip_address" {
  description = "Associated public ip address"
  type    = bool
}

variable "vpc_id"{
  description = "Id of VPC"
  type    = string
}

variable "security_group_id"{
  description = "Id of security group"
  type    = string
}

variable "random_pet"{
  type    = string
}

locals {
  availability_zone       = "${var.region}c"
  tag_name                = "${var.tag_name}_${var.random_pet}"
  iam_role_name           = "${var.instance_name}_iam_role_${var.random_pet}"
  instance_profile_name   = "${var.instance_name}_instance_profile_${var.random_pet}"
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

//----------Creates the AWS EC2 instance----------

resource "aws_instance" "the_instance" {
  ami                   = var.ami_id
  instance_type         = var.instance_type
  availability_zone     = local.availability_zone
  associate_public_ip_address = var.associate_public_ip_address
  key_name                = var.key_name
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids    = [
    var.security_group_id
  ]
  tags  = {
    Name = local.tag_name
  }
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  private_dns_name_options{
    enable_resource_name_dns_a_record = true
    hostname_type = "ip-name"
  }
  depends_on = [ var.security_group_id ]
}

//----------Instance Profile and role attachment----------

resource "aws_iam_instance_profile" "ec2_profile" {
  name = local.instance_profile_name
  role = aws_iam_role.ec2_instance_role.name
}

//----------IAM Rol creation----------

//Defines an IAM role that allows EC2 to access resources in your AWS account.

resource "aws_iam_role" "ec2_instance_role" {
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
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

//Terraform(AWS) EC2 and SSM (Aws System Manager)
//https://medium.com/@khimananda.oli/terraform-aws-ec2-and-system-manager-e0f0c914132c

//----------Policy assignment to the IAM Rol----------

//Attaches a policy to the IAM role.
//AmazonEC2FullAccess Provides full access to Amazon EC2 via the AWS Management Console.
resource "aws_iam_role_policy_attachment" "aws_ec2_access_execution_role" {
  role        = aws_iam_role.ec2_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

//Attaches a policy to the IAM role.
//AmazonSSMFullAccess Provides full access to Amazon SSM.
resource "aws_iam_role_policy_attachment" "aws_ssm_access_execution_role" {
  role        = aws_iam_role.ec2_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

//Attaches a policy to the IAM role.
//AmazonSSMFullAccess Provides full access to Amazon SSM.
resource "aws_iam_role_policy_attachment" "aws_cloudwatch_access_execution_role" {
  role        = aws_iam_role.ec2_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

//Attaches a policy to the IAM role.
//AmazonSSMManagedInstanceCore The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.
resource "aws_iam_role_policy_attachment" "aws_ssm_managed_execution_role" {
  role        = aws_iam_role.ec2_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


//----------Associating Public IP----------
/*
resource "aws_eip" "lb" {
  instance = aws_instance.the_instance.id
  vpc      = true
}
*/
##################################################################################
# aws_instance - OUTPUT
##################################################################################

output "aws_instance_id" {
  description = "Instance Id"
  value = aws_instance.the_instance.id
}

output "aws_instance_name" {
  description = "Instance Name"
  value = aws_instance.the_instance.tags
}

output "aws_instance_public_ip" {
  description = "Public IP"
  value = aws_instance.the_instance.public_ip
}

output "aws_instance_private_ip" {
  description = "Private IP"
  value = aws_instance.the_instance.private_ip
}
