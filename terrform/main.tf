provider "aws" {
  region = "us-east-1"
  shared_config_files = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

# ----------------------
# VPC and Networking
# ----------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "sm-statuspage-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "sm-statuspage-igw" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

# ----------------------
# Security Groups
# ----------------------
resource "aws_security_group" "sm_admin_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust for security
  }
}

resource "aws_security_group" "sm_user_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------
# EKS Cluster
# ----------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "sm-statuspage-eks"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true
  cluster_security_group_id = aws_security_group.sm_admin_sg.id

  eks_managed_node_groups = {
    worker_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = ["t3.medium"]
      subnet_ids     = ["10.0.3.0/24", "10.0.4.0/24"]
      security_groups = [aws_security_group.sm_user_sg.id]
    }
  }
}

# ----------------------
# RDS Database
# ----------------------
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "sm-statuspage-postgresql"
  engine     = "postgres"
  engine_version = "14"
  instance_class = "db.t3.medium"
  allocated_storage = 10

  username = "statuspage"
  password = "abcdefgh123456"
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.sm_admin_sg.id]
  subnet_ids = ["10.0.3.0/24"]
}


#data "aws_secretsmanager_secret" "rds_secret" {
#  name = "rds-credentials"
#}

#data "aws_secretsmanager_secret_version" "rds_secret_version" {
#  secret_id = data.aws_secretsmanager_secret.rds_secret.id
#}

#  username = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
#  password = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
