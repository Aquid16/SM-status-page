output "rds_endpoint" {
  value = aws_db_instance.statuspage_db.endpoint
}

output "efs_filesystem_id" {
  value = aws_efs_file_system.statuspage_efs.id
}
