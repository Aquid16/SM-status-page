# -----------------------------------
# RDS Database Module
# -----------------------------------

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "rds/terraform.tfstate"
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

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "security_groups/terraform.tfstate"
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


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  tags = {
    Name  = "${var.identifier}-subnet-group"
    Owner = local.owner
  }
}

resource "aws_db_parameter_group" "custom_pg" {
  name   = "${var.identifier}-pg"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "${var.identifier}-pg"
    Owner = local.owner
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier          = var.identifier
  engine              = "postgres"
  engine_version      = "17"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20

  db_name             = var.database_name
  username            = var.username
  password            = var.password
  publicly_accessible = false

  vpc_security_group_ids = [data.terraform_remote_state.security_groups.outputs.admin_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name  

  family = "postgres17"

  parameter_group_name = aws_db_parameter_group.custom_pg.name
  
  tags = {
    Name  = var.identifier
    Owner = local.owner
  }
}