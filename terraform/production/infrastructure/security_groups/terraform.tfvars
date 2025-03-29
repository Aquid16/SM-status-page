output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
  description = "The ID of the bastion security group"
}