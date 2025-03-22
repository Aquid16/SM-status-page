output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.efs.id
}