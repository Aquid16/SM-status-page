variable "efs_name" {
  description = "Name of the EFS file system"
  type        = string
  default     = "sm-efs"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EFS mount targets"
  type        = string
}