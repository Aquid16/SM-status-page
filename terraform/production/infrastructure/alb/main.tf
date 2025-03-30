# ALB

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sharon-meital-terraform-state-bucket"
    key    = "alb/terraform.tfstate"
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


# Reference your existing hosted zone
data "aws_route53_zone" "status_page" {
  zone_id = "Z02801181XR3LNYC5CSWI"
}

# Get the specific ALB created by the ingress in production namespace
data "aws_lb" "eks_alb" {
  tags = {
    "elbv2.k8s.aws/cluster"       = "sm-statuspage-eks"
    "ingress.k8s.aws/stack"       = "sm-status-page"  
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
resource "aws_route53_record" "grafana_sm_status_page" {
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
