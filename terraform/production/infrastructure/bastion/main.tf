# Bastion Host Security Group

provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "bastion/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "sm-bastion-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow SSH access to Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sm-bastion-sg"
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-04b4f1a9cf54c11d0"  
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key_name
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              # Install git
              sudo apt-get install -y git
              # Install aws-cli
              snap install aws-cli --classic
              # Install kubectl
              sudo snap install kubectl --classic

              # Install Helm
              curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
              chmod 700 get_helm.sh
              ./get_helm.sh
              
              EOF
  tags = {
    Name = "sm-bastion-host"
  }
}