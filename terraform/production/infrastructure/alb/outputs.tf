output "status_page_dns" {
  value       = aws_route53_record.sm_status_page.fqdn
  description = "The fully qualified domain name of the status page"
}

output "alb_dns_name" {
  value       = data.aws_lb.eks_alb.dns_name
  description = "The DNS name of the ALB"
}
