output "bastion_sg_id" {
  description = "ID of the Bastion Host security group"
  value       = aws_security_group.bastion_sg.id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "status_page_dns" {
  value       = aws_route53_record.sm_status_page.fqdn
  description = "The fully qualified domain name of the status page"
}

output "alb_dns_name" {
  value       = data.aws_lb.eks_alb.dns_name
  description = "The DNS name of the ALB"
}