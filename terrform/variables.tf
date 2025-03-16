# -----------------------------------
# Root-Level Variable Definitions
# -----------------------------------

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks for private subnets (for security groups)"
  type        = list(string)
}


variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}

variable "rds_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "rds_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "rds_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "rds_database_name" {
  description = "Name of the initial database"
  type        = string
}