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

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "bastion/terraform.tfstate"
    region = "us-east-1"
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
    security_groups = [data.terraform_remote_state.bastion.outputs.bastion_sg_id]
    description = "Allow Kubernetes API access from Bastion Host"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    description = "Allow NFS traffic for EFS from private subnets"
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
  }
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
  }
}