provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "access_entries/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_eks_access_entry" "sm_user" {
  count         = length(var.principal_arns)
  cluster_name  = data.terraform_remote_state.eks.outputs.cluster_name
  principal_arn = var.principal_arns[count.index]
  type          = "STANDARD"
  kubernetes_groups = ["eks-admins"]
}

resource "aws_eks_access_policy_association" "sm_user_admin" {
  count         = length(var.principal_arns)
  cluster_name  = data.terraform_remote_state.eks.outputs.cluster_name
  principal_arn = var.principal_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.sm_user]
}