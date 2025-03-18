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
      subnet_ids     = var.subnet_ids
      additional_security_group_ids = [var.user_sg_id]
      iam_role_arn = var.node_group_role_arn
    }
  }

  tags = {
    Name  = var.cluster_name
  }
}