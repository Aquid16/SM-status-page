output "bastion_sg_id" {
  description = "ID of the Bastion Host security group"
  value       = aws_security_group.bastion_sg.id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}