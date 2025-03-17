resource "aws_eks_access_entry" "sm_user" {
  count         = length(var.principal_arns)
  cluster_name  = var.cluster_name
  principal_arn = var.principal_arns[count.index]
  type          = "STANDARD"
  kubernetes_groups = ["system:masters"]
}

resource "aws_eks_access_policy_association" "sm_user_admin" {
  count         = length(var.principal_arns)
  cluster_name  = var.cluster_name
  principal_arn = var.principal_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.sm_user]
}