resource "aws_instance" "docker_host" {
  ami                         = data.aws_ssm_parameter.ubuntu_lts_ami.value
  instance_type               = var.docker_host_instance_type
  subnet_id                   = aws_subnet.public[var.docker_host_subnet_az].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.docker_host.name
  vpc_security_group_ids      = [aws_security_group.docker_host.id]
  monitoring                  = var.docker_host_detailed_monitoring
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/../scripts/ubuntu_bootstrap_v01", {
    efs_dns_name   = aws_efs_file_system.docker_data.dns_name
    efs_mount_path = var.efs_mount_path
  })

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  root_block_device {
    volume_size           = var.docker_host_root_volume_size_gb
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name      = "${local.name_prefix}-docker-host-root"
      Component = "docker-host"
      Purpose   = "os"
    }
  }

  tags = {
    Name      = "${local.name_prefix}-docker-host"
    Component = "docker-host"
    Role      = "docker-host"
  }
}
