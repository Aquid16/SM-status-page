output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.efs.id
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = aws_efs_access_point.efs_access_point.id
}