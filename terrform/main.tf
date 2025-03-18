# -----------------------------------
# Main Terraform Configuration
# -----------------------------------

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# Bastion Host
module "bastion" {
  source = "./modules/bastion"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnets[0]
  ssh_key_name     = var.ssh_key_name
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id          = module.vpc.vpc_id
  private_subnets = var.private_subnets_cidr_blocks
  bastion_sg_id   = module.bastion.bastion_sg_id
}

# EKS Cluster
module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  admin_sg_id         = module.security_groups.admin_sg_id
  user_sg_id          = module.security_groups.user_sg_id
  desired_size        = var.node_group_desired_size
  max_size            = var.node_group_max_size
  min_size            = var.node_group_min_size
  instance_types      = var.node_instance_types
  iam_role_arn        = var.eks_cluster_role_arn
  node_group_role_arn = var.eks_node_group_role_arn
}

module "access_entries" {
  source = "./modules/access_entries"
  cluster_name   = module.eks.cluster_name
  principal_arns = var.principal_arns  
  depends_on     = [module.eks]
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  identifier          = var.rds_identifier
  username            = var.rds_username
  password            = var.rds_password
  database_name       = var.rds_database_name
  vpc_security_group_ids = [module.security_groups.admin_sg_id]
  subnet_ids          = module.vpc.private_subnets
}