# -----------------------------------
# VPC and Networking
# -----------------------------------
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
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# -----------------------------------
# Security Groups
# -----------------------------------
resource "aws_security_group" "admin_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "sm-admin-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this for better security
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sm-admin-sg"
  }
}

resource "aws_security_group" "user_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "sm-user-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sm-user-sg"
  }
}

# -----------------------------------
# EKS Cluster
# -----------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa              = true
  cluster_security_group_id = aws_security_group.admin_sg.id

  eks_managed_node_groups = {
    worker_nodes = {
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size

      instance_types = var.node_instance_types
      subnet_ids     = module.vpc.private_subnets
      security_groups = [aws_security_group.user_sg.id]
    }
  }

  tags = {
    Name = var.cluster_name
  }
}

# -----------------------------------
# RDS Database
# -----------------------------------
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier          = var.rds_identifier
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = "db.t3.medium"
  allocated_storage   = 10

  username             = var.rds_username
  password             = var.rds_password
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.admin_sg.id]
  subnet_ids           = module.vpc.private_subnets

  family = "postgres14"

  tags = {
    Name = var.rds_identifier
  }
}

# Optional: Uncomment to use AWS Secrets Manager for RDS credentials
#data "aws_secretsmanager_secret" "rds_secret" {
#  name = "rds-credentials"
#}
#
#data "aws_secretsmanager_secret_version" "rds_secret_version" {
#  secret_id = data.aws_secretsmanager_secret.rds_secret.id
#}
#
#module "rds" {
#  ...
#  username = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
#  password = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
#  ...
#}