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

data "terraform_remote_state" "security_groups" {
  backend = "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "security_groups/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "efs" {
  backend = "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "efs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3" {
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

              # Retrieve AWS credentials from Secrets Manager
              SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id <your-secret-id> --region us-east-1 | jq -r .SecretString)
              AWS_ACCESS_KEY_ID=$(echo $SECRET_JSON | jq -r .aws_access_key_id)
              AWS_SECRET_ACCESS_KEY=$(echo $SECRET_JSON | jq -r .aws_secret_access_key)

              # Configure AWS CLI with the retrieved credentials
              aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
              aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
              aws configure set region "us-east-1"

              # Wait for EKS and configure kubeconfig
              aws eks update-kubeconfig --region us-east-1 --name ${data.terraform_remote_state.eks.outputs.cluster_name}

              # Create the production namespace and set it as default
              kubectl create namespace production
              kubectl config set-context --current --namespace=production

              # Add Helm repositories for EBS and EFS drivers
              helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
              helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
              helm repo update

              # Install AWS EBS CSI Driver
              helm install ebs-csi aws-ebs-csi-driver/aws-ebs-csi-driver \
                --namespace kube-system \
                --set controller.serviceAccount.create=true

              # Install AWS EFS CSI Driver
              helm install efs-csi aws-efs-csi-driver/aws-efs-csi-driver \
                --namespace kube-system \
                --set controller.serviceAccount.create=true

              # Clone your Git repository
              git clone https://github.com/Aquid16/SM-status-page.git 
              cd SM-status-page/Helm/production

              # Run the existing create-alb-irsa.sh script
              chmod +x create-alb-irsa.sh
              ./create-alb-irsa.sh

              # Install Helm charts from the Git repository - status page
              helm install efs efs-sc-stack --set fileSystemId=${data.terraform_remote_state.efs.outputs.efs_id}
              helm install status-page status-page-stack
              EOF

              # Install Helm charts from the Git repository - observability
              cd ~/SM-status-page/Helm/observability/observability-stack
              helm install observability ./ -f values.yaml -f values-loki.yaml -f values-fluent-bit.yaml --namespace observability --create-namespace
              EOF
              


  tags = {
    Name = "sm-bastion-host"
    Owner = local.owner
  }
}


# Reference your existing hosted zone
data "aws_route53_zone" "status_page" {
  zone_id = "Z02801181XR3LNYC5CSWI"
}

# Get the specific ALB created by the ingress in production namespace
data "aws_lb" "eks_alb" {
  depends_on = [aws_instance.bastion]
  tags = {
    "elbv2.k8s.aws/cluster"       = data.terraform_remote_state.eks.outputs.cluster_name
    "ingress.k8s.aws/namespace"   = "production"  # Match the namespace from your user_data
    "ingress.k8s.aws/resource"    = "LoadBalancer"
  }
}

# Create the Route 53 A record with alias to ALB - statuspage
resource "aws_route53_record" "sm_status_page" {
  zone_id = data.aws_route53_zone.status_page.zone_id
  name    = "sm-status-page.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_alb.dns_name
    zone_id                = data.aws_lb.eks_alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [data.aws_lb.eks_alb]
}

# Create the Route 53 A record with alias to ALB - grafana
resource "aws_route53_record" "sm_status_page" {
  zone_id = data.aws_route53_zone.status_page.zone_id
  name    = "grafana.sm-status-page.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_alb.dns_name
    zone_id                = data.aws_lb.eks_alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [data.aws_lb.eks_alb]
}