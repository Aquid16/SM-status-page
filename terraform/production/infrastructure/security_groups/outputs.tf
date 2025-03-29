# -----------------------------------
# Security Groups Module Outputs
# -----------------------------------

output "admin_sg_id" {
  description = "ID of the admin security group"
  value       = aws_security_group.admin_sg.id
}

output "user_sg_id" {
  description = "ID of the user security group"
  value       = aws_security_group.user_sg.id
}

output "bastion_sg_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion_sg.id
}
