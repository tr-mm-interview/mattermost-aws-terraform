resource "aws_efs_file_system" "docker_data" {
  creation_token   = "${local.name_prefix}-docker-data"
  encrypted        = true
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode

  lifecycle_policy {
    transition_to_ia = var.efs_transition_to_ia
  }

  tags = {
    Name      = "${local.name_prefix}-efs-docker-data"
    Component = "efs"
    Purpose   = "persistent-app-data"
  }
}

resource "aws_efs_backup_policy" "docker_data" {
  file_system_id = aws_efs_file_system.docker_data.id

  backup_policy {
    status = var.efs_backup_enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_efs_mount_target" "docker_data" {
  for_each = aws_subnet.public

  file_system_id  = aws_efs_file_system.docker_data.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs.id]
}
