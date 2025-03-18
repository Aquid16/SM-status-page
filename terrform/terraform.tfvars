# AWS Region
aws_region 	    = "us-east-1"

# VPC Module Variables
vpc_name            = "sm-statuspage-vpc"
vpc_cidr            = "10.0.0.0/16"
azs                 = ["us-east-1a", "us-east-1b"]
public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]

# Security Groups Module Variables
private_subnets_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]

# EKS Module Variables
cluster_name        = "sm-statuspage-eks"
cluster_version     = "1.31"
node_group_desired_size = 2
node_group_max_size     = 2
node_group_min_size     = 2
node_instance_types     = ["t3.medium"]

principal_arns      = [
  "arn:aws:iam::992382545251:user/meitaltal",
  "arn:aws:iam::992382545251:user/SharonSinelnikov"
]

# RDS Module Variables
rds_identifier      = "sm-statuspage-postgresql"
rds_username        = "statuspage"
rds_password        = "abcdefgh123456"
rds_database_name   = "statuspage"
