variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for the Bastion"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}