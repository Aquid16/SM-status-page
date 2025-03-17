output "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  value       = aws_iam_role.eks_node_group_role.arn
}