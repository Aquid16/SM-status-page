variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
}

variable "instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  type        = string
}