variable "identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "username" {
  description = "Username for the RDS database"
  type        = string
}

variable "password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the initial database"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}