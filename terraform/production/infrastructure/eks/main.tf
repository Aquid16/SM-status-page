# -----------------------------------
# EKS Cluster Module
# -----------------------------------

provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  enable_irsa              = true

  cluster_security_group_id = data.terraform_remote_state.security_groups.outputs.admin_sg_id
  create_cluster_security_group = false
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  iam_role_arn = var.iam_role_arn

  eks_managed_node_groups = {
    sm_worker_nodes = {
      name = "sm-worker-nodes"
      desired_size = var.desired_size
      max_size     = var.max_size
      min_size     = var.min_size
      instance_types = var.instance_types
      subnet_ids     = data.terraform_remote_state.vpc.outputs.private_subnets
      additional_security_group_ids = [data.terraform_remote_state.security_groups.outputs.user_sg_id]
      iam_role_arn = var.node_group_role_arn
    }
  }

  tags = {
    Name  = var.cluster_name
    Owner = local.owner
  }
}