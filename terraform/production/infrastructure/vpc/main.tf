# -----------------------------------
# VPC and Networking Module
# -----------------------------------

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  nat_gateway_tags = {
    Name = "sm-statuspage-nat"
    Owner = local.owner
  }

  igw_tags = {
    Name = "sm-statuspage-igw"
    Owner = local.owner
  }

  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "Name" = "${var.vpc_name}-public"
    Owner = local.owner
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "Name" = "${var.vpc_name}-private"
    Owner = local.owner
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_route_table_tags = {
    Name = "${var.vpc_name}-public-rt"
    Owner = local.owner
  }

  private_route_table_tags = {
    Name = "${var.vpc_name}-private-rt"
    Owner = local.owner
  }

  manage_default_vpc = false
  manage_default_security_group = false
  manage_default_route_table = false
  manage_default_network_acl = false

  tags = {
    Name  = var.vpc_name
    Owner = local.owner
  }
}