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

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "security_groups/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "efs" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "efs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}


# Get the current AWS caller identity
data "aws_caller_identity" "current" {}

# Get the IAM user details based on the caller identity
data "aws_iam_user" "current_user" {
  user_name = element(split("/", data.aws_caller_identity.current.arn), 1)
}

# Define the owner dynamically
locals {
  owner = data.aws_iam_user.current_user.user_name
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-04b4f1a9cf54c11d0"  
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [data.terraform_remote_state.security_groups.outputs.bastion_sg_id]
  key_name      = var.ssh_key_name
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash

              # Switch to the home directory of ubuntu user
              cd /home/ubuntu

              # Update the package list
              sudo apt-get update -y
              
              # Install git
              sudo apt-get install -y git
              
              # Install AWS CLI and kubectl via snap and eksctl 
              sudo snap install aws-cli --classic
              sudo snap install kubectl --classic
              sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C /usr/local/bin

              # Install Helm
              curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
              chmod 700 get_helm.sh
              ./get_helm.sh

              # Configure AWS CLI with credentials from Terraform variables
              mkdir -p /home/ubuntu/.aws
              echo "[default]" > /home/ubuntu/.aws/credentials
              echo "aws_access_key_id = ${var.aws_access_key}" >> /home/ubuntu/.aws/credentials
              echo "aws_secret_access_key = ${var.aws_secret_key}" >> /home/ubuntu/.aws/credentials
              echo "region = us-east-1" >> /home/ubuntu/.aws/credentials
              chown ubuntu:ubuntu /home/ubuntu/.aws/credentials
              chmod 600 /home/ubuntu/.aws/credentials
              aws sts get-caller-identity

              # Wait for EKS and configure kubeconfig
              sudo -u ubuntu aws eks update-kubeconfig --region us-east-1 --name sm-statuspage-eks
              # Create the production namespace and set it as default
              sudo -u ubuntu kubectl create namespace production
              sudo -u ubuntu kubectl config set-context --current --namespace=production

              # Add Helm repositories for EBS and EFS drivers
              sudo -u ubuntu helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
              sudo -u ubuntu helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
              sudo -u ubuntu helm repo update

              # Install AWS EBS CSI Driver
              sudo -u ubuntu helm install ebs-csi aws-ebs-csi-driver/aws-ebs-csi-driver \
                --namespace kube-system \
                --set controller.serviceAccount.create=true

              # Install AWS EFS CSI Driver
              sudo -u ubuntu helm install efs-csi aws-efs-csi-driver/aws-efs-csi-driver \
                --namespace kube-system \
                --set controller.serviceAccount.create=true

              # Clone your Git repository
              git clone https://github.com/Aquid16/SM-status-page.git 
              cd SM-status-page/Helm/production

              # Run the existing create-alb-irsa.sh script
              sudo -u ubuntu chmod +x create-alb-irsa.sh
              sudo -u ubuntu ./create-alb-irsa.sh

              # Install Helm charts from the Git repository - status page
              sudo -u ubuntu helm install redis redis-stack
              sudo -u ubuntu helm install efs efs-sc-stack --set fileSystemId=${data.terraform_remote_state.efs.outputs.efs_id}
              sudo -u ubuntu helm install status-page status-page-stack

              # Install Helm charts from the Git repository - observability
              cd -
              cd SM-status-page/Helm/observability/observability-stack
              sudo -u ubuntu helm install observability ./ -f values.yaml -f values-loki.yaml -f values-fluent-bit.yaml --namespace observability --create-namespace
              EOF
              
  tags = {
    Name = "sm-bastion-host"
    Owner = local.owner
  }
}
