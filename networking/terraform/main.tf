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

variable "security_group_name"{
  type    = string
}

data "http" "local_home_ip_address" {
  url = "https://ifconfig.me/ip"
}
/*
variable "k8s_eip_nat2_the_public_ip"{
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

//----------Look up the default vpc----------

resource "aws_default_vpc" "default" { }

//----------Create The Security Group--------------
resource "aws_security_group" "the_security_group" {
  name        = var.security_group_name
  description = var.security_group_name
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }  
}

//-------Self security Group---------------------------

resource "aws_security_group_rule" "ingress_from_self_security_group" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_self_${aws_security_group.the_security_group.id}"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  self              = true  
}

//-------Egress to everywhere---------------------------

resource "aws_security_group_rule" "egress_to_everywhere" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "egress_to_everywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks      = ["0.0.0.0/0"]
}

//-------Dynamic Home IPs for Dev/Tools ---------------------------

resource "aws_security_group_rule" "ingress_from_local_home_to_postgresql" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_postgresql"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}
/*
resource "aws_security_group_rule" "ingress_from_k8s_to_postgresql" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_k8s_to_postgresql"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks      = ["${var.k8s_eip_nat2_the_public_ip}/32"]  
}
*/
resource "aws_security_group_rule" "ingress_from_local_home_to_ssh" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3000" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3000"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3001" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3001"
  type              = "ingress"
  from_port         = 3001
  to_port           = 3001
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3002" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3002"
  type              = "ingress"
  from_port         = 3002
  to_port           = 3002
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3003" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3003"
  type              = "ingress"
  from_port         = 3003
  to_port           = 3003
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3004" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3004"
  type              = "ingress"
  from_port         = 3004
  to_port           = 3004
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_3005" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_3005"
  type              = "ingress"
  from_port         = 3005
  to_port           = 3005
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_50055" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_50055"
  type              = "ingress"
  from_port         = 50055
  to_port           = 50055
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

resource "aws_security_group_rule" "ingress_from_local_home_to_50056" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_local_home_to_50056"
  type              = "ingress"
  from_port         = 50056
  to_port           = 50056
  protocol          = "tcp"
  cidr_blocks      = ["${data.http.local_home_ip_address.response_body}/32"]
}

//-------Static IPs for Prod/Jenkins ---------------------------
/*
resource "aws_security_group_rule" "ingress_from_server_jenkins_to_postgresql" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_postgresql"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"] 
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_ssh" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_k8s_to_postgresql" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_k8s_to_postgresql"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks      = ["${var.k8s_eip_nat2_the_public_ip}/32"]  
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_3000" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_3000"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_3001" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_3001"
  type              = "ingress"
  from_port         = 3001
  to_port           = 3001
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_3002" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_3002"
  type              = "ingress"
  from_port         = 3002
  to_port           = 3002
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_3003" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_3003"
  type              = "ingress"
  from_port         = 3003
  to_port           = 3003
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_3004" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_3004"
  type              = "ingress"
  from_port         = 3004
  to_port           = 3004
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_50055" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_50055"
  type              = "ingress"
  from_port         = 50055
  to_port           = 50055
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}

resource "aws_security_group_rule" "ingress_from_server_jenkins_to_50056" {
  security_group_id = aws_security_group.the_security_group.id
  description       = "ingress_from_server_jenkins_to_50056"
  type              = "ingress"
  from_port         = 50056
  to_port           = 50056
  protocol          = "tcp"
  cidr_blocks      = ["186.155.14.59/32"]
}
*/
##################################################################################
# aws_security_group - OUTPUT
##################################################################################

output "security_group" {
  description = "Security Group "
  value = aws_security_group.the_security_group
}

output "security_group_name" {
  description = "Security Group Name"
  value = aws_security_group.the_security_group.name
}

output "security_group_id" {
  description = "Security Group Id"
  value = aws_security_group.the_security_group.id
}

output "security_group_vpc_id" {
  description = "Security Group Vpc Id"
  value = aws_security_group.the_security_group.vpc_id
}

output "vpc_id" {
  description = "Local Home Ip Address"
  value = aws_default_vpc.default.id
}

output "local_home_ip_address" {
  value = data.http.local_home_ip_address.response_body
}
