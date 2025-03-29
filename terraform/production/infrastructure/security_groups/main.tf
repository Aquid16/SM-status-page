# -----------------------------------
# Security Groups Module
# -----------------------------------

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "security_groups/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Get the current AWS caller identity
data "aws_caller_identity" "current" {}

# Get the IAM user details based on the caller identity
data "aws_iam_user" "current_user" {
  user_name = element(split("/", data.aws_caller_identity.current.arn), 1)
}

# Define the owner dynamically
locals {
  owner = data.aws_iam_user.current_user.user_name
}


resource "aws_security_group" "bastion_sg" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "sm-bastion-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access to Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name  = "sm-bastion-sg"
    Owner = local.owner
  }
}


resource "aws_security_group" "admin_sg" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "sm-admin-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    description = "Allow SSH from private subnets"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    description = "Allow Kubernetes API from private subnets"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description = "Allow Kubernetes API access from Bastion Host"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    description = "Allow NFS traffic for EFS from private subnets"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    description = "Allow PostgresSQL traffic from private subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name  = "sm-admin-sg"
    Owner = local.owner
  }
  
  depends_on = [aws_security_group.bastion_sg]
}

resource "aws_security_group" "user_sg" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "sm-user-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from the internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name  = "sm-user-sg"
    Owner = local.owner
  }
}
