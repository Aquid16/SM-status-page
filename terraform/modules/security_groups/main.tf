# -----------------------------------
# Security Groups Module
# -----------------------------------
resource "aws_security_group" "admin_sg" {
  vpc_id = var.vpc_id
  name   = "sm-admin-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
    description = "Allow SSH from private subnets"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
    description = "Allow Kubernetes API from private subnets"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.bastion_sg_id]
    description = "Allow Kubernetes API access from Bastion Host"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
    description = "Allow NFS traffic for EFS from private subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name  = "sm-admin-sg"
  }
}

resource "aws_security_group" "user_sg" {
  vpc_id = var.vpc_id
  name   = "sm-user-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from the internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name  = "sm-user-sg"
  }
}