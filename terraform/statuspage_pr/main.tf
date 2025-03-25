data "aws_caller_identity" "current" {}

data "aws_iam_user" "current_user" {
  user_name = element(split("/", data.aws_caller_identity.current.arn), 1)
}

# Fetch the existing VPC
data "aws_vpc" "sm_statuspage" {
  filter {
    name   = "tag:Name"
    values = ["sm-statuspage-vpc"]
  }
}

# Fetch private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sm_statuspage.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.3.0/24", "10.0.4.0/24"]
  }
}

# Fetch security group (assuming it's already created)
data "aws_security_group" "sg" {
  filter {
    name   = "group-name"
    values = ["sm-user-sg"] # Replace with the actual SG name
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sm_statuspage.id]
  }
}

# Create a Private ECR Repository
resource "aws_ecr_repository" "statuspage_repo" {
  name = "sm-statuspage-test-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
  Name  = "sm-statuspage-test-repo"
  Owner = data.aws_iam_user.current_user.user_name
  Environment = "Test"
  }
}

# Create an RDS Instance
resource "aws_db_instance" "statuspage_db" {
  identifier            = "sm-statuspage-test-db"
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20

  db_name              = "statuspage"
  username            = "statuspage"
  password            = "abcdefgh123456"
  parameter_group_name = "default.postgres17"
  publicly_accessible  = false

  # Attach to the correct VPC and security groups
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  db_subnet_group_name   = aws_db_subnet_group.statuspage_subnet_group.name

  skip_final_snapshot = true

  tags = {
  Name  = "sm-statuspage-test-db"
  Owner = data.aws_iam_user.current_user.user_name
  Environment = "Test"
  }
}

# RDS Subnet Group (using private subnets)
resource "aws_db_subnet_group" "statuspage_subnet_group" {
  name       = "sm-statuspage-test-db-subnet-group"
  subnet_ids = data.aws_subnets.private.ids
  description = "Subnet group for StatusPage RDS instance sm-test"
}

resource "aws_efs_file_system" "statuspage_efs" {
  creation_token = "sm-efs-test"
  encrypted      = true
  tags = {
    Name = "sm-efs-test"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "efs_mount_test" {
  count           = length(data.aws_subnets.private.ids)
  file_system_id  = aws_efs_file_system.statuspage_efs.id
  subnet_id       = data.aws_subnets.private.ids[count.index]
  security_groups = [data.aws_security_group.sg.id]
}

data "aws_eks_cluster" "cluster" {
  name = "sm-statuspage-eks"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "sm-statuspage-eks"
}

# --- HELM PROVIDER ---
#data "aws_ecr_authorization_token" "example" {}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    host        = data.aws_eks_cluster.cluster.endpoint
    token       = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  }
}

#resource "helm_repository" "my_repo" {
#  name     = "sharon-meital/statuspage"
#  url      = "https://992382545251.dkr.ecr.us-east-1.amazonaws.com"
#  username = data.aws_ecr_authorization_token.example.username
#  password = data.aws_ecr_authorization_token.example.password
#}

# --- REDIS ---
resource "helm_release" "redis" {
  name       = "redis"
  namespace  = "development"
  chart      = "SM-status-page/Helm/statuspage_pr/redis-stack"  # Changed to a relative path
  wait       = true
}

# --- EFS STORAGE CLASS ---
resource "helm_release" "efs" {
  name       = "efs"
  namespace  = "development"
  chart      = "SM-status-page/Helm/statuspage_pr/efs-sc-stack"  # Changed to a relative path
  wait       = true

  set {
    name  = "EFS_FILE_SYSTEM_ID"
    value = aws_efs_file_system.statuspage_efs.id
  }
}

# --- STATUS PAGE HELM RELEASE ---
resource "helm_release" "statuspage" {
  name       = "status-page"
  namespace  = "development"
  chart      = "SM-status-page/Helm/statuspage_pr/status-page-stack"
  wait       = true

  set {
    name  = "DATABASE_HOST"
    value = aws_db_instance.statuspage_db.endpoint
  }
}
