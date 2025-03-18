# EFS File System
resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_name
  encrypted      = true
  tags = {
    Name = var.efs_name
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "efs_mount" {
  count          = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.subnet_ids[count.index]
  security_groups = [var.security_group_id]
}

# EFS Access Point - optional
resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/status-page"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
  tags = {
    Name = "${var.efs_name}-access-point"
  }
}