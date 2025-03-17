variable "vpc_id" {
    description = "The ID of the VPC where the security group will be created"
    type = string
}

variable "private_subnets" {
    description = "CIDR blocks for private subnets"
    type = list(string)
}