# -----------------------------------
# VPC and Networking Module
# -----------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  nat_gateway_tags = {
    Name = "sm-statuspage-nat"
  }

  igw_tags = {
    Name = "sm-statuspage-igw"
  }

  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "Name" = "${var.vpc_name}-public"
  }

  private_subnet_tags = {
    "Name" = "${var.vpc_name}-private"
  }

  public_route_table_tags = {
    Name = "${var.vpc_name}-public-rt"
  }

  private_route_table_tags = {
    Name = "${var.vpc_name}-private-rt"
  }

  manage_default_vpc = false
  manage_default_security_group = false
  manage_default_route_table = false
  manage_default_network_acl = false

  tags = {
    Name  = var.vpc_name
  }
}