# -----------------------------------
# EKS Cluster Module
# -----------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa              = true
  cluster_security_group_id = var.admin_sg_id

  eks_managed_node_groups = {
    worker_nodes = {
      desired_size = var.desired_size
      max_size     = var.max_size
      min_size     = var.min_size

      instance_types = var.instance_types
      subnet_ids     = var.subnet_ids
      security_groups = [var.user_sg_id]
    }
  }

  tags = {
    Name  = var.cluster_name
  }
}