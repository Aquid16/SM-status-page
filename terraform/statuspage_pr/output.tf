output "rds_endpoint" {
  value = aws_db_instance.statuspage_db.endpoint
}

output "efs_filesystem_id" {
  value = aws_efs_file_system.statuspage_efs.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip  # Adjust based on your bastion resource name
}
