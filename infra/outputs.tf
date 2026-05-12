output "aws_account_id" {
  description = "AWS account ID Terraform is deploying into."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region Terraform is deploying into."
  value       = data.aws_region.current.region
}

output "vpc_id" {
  description = "Main VPC ID."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the main VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks by Availability Zone."
  value = {
    for az, subnet in aws_subnet.public : az => subnet.cidr_block
  }
}

output "public_subnet_availability_zones" {
  description = "Availability Zones used for public subnets."
  value       = keys(aws_subnet.public)
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "docker_host_instance_id" {
  description = "EC2 instance ID for the Docker host."
  value       = aws_instance.docker_host.id
}

output "docker_host_availability_zone" {
  description = "Availability Zone where the Docker host is running."
  value       = aws_instance.docker_host.availability_zone
}

output "docker_host_public_ip" {
  description = "Public IPv4 address for the Docker host."
  value       = aws_instance.docker_host.public_ip
}

output "docker_host_private_ip" {
  description = "Private IPv4 address for the Docker host."
  value       = aws_instance.docker_host.private_ip
}

output "docker_host_security_group_id" {
  description = "Security group ID attached to the Docker host."
  value       = aws_security_group.docker_host.id
}

output "docker_host_iam_role_name" {
  description = "IAM role name attached to the Docker host."
  value       = aws_iam_role.docker_host.name
}

output "docker_host_instance_profile_name" {
  description = "IAM instance profile name attached to the Docker host."
  value       = aws_iam_instance_profile.docker_host.name
}

output "ansible_ssm_bucket_name" {
  description = "S3 bucket name used by Ansible's AWS SSM connection plugin for module transfer."
  value       = aws_s3_bucket.ansible_ssm.bucket
}

output "ansible_ssm_bucket_arn" {
  description = "S3 bucket ARN used by Ansible's AWS SSM connection plugin for module transfer."
  value       = aws_s3_bucket.ansible_ssm.arn
}

output "ansible_deployer_policy_arn" {
  description = "IAM policy ARN for local or CI deploy identities that run Ansible through AWS SSM."
  value       = aws_iam_policy.ansible_deployer.arn
}

output "efs_file_system_id" {
  description = "EFS file system ID for Docker persistent application data."
  value       = aws_efs_file_system.docker_data.id
}

output "efs_dns_name" {
  description = "Regional DNS name for the Docker persistent storage EFS file system."
  value       = aws_efs_file_system.docker_data.dns_name
}

output "efs_security_group_id" {
  description = "Security group ID attached to the EFS mount targets."
  value       = aws_security_group.efs.id
}

output "efs_mount_target_ids" {
  description = "EFS mount target IDs by Availability Zone."
  value = {
    for az, mount_target in aws_efs_mount_target.docker_data : az => mount_target.id
  }
}

output "efs_mount_path" {
  description = "Mount path for the shared Docker persistent storage EFS file system on the Docker host."
  value       = var.efs_mount_path
}

output "mattermost_nlb_dns_name" {
  description = "DNS name of the public Mattermost Network Load Balancer."
  value       = aws_lb.mattermost.dns_name
}

output "mattermost_route53_hostname" {
  description = "Route 53 hostname for the Mattermost demo."
  value       = aws_route53_record.mattermost.fqdn
}

output "mattermost_target_group_arn" {
  description = "ARN of the Mattermost TLS target group."
  value       = aws_lb_target_group.mattermost.arn
}

output "mattermost_https_listener_arn" {
  description = "ARN of the Mattermost NLB TLS listener."
  value       = aws_lb_listener.mattermost_https.arn
}

output "mattermost_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Mattermost NLB TLS listener."
  value       = local.nlb_certificate_arn
}

output "mattermost_db_password_secret_arn" {
  description = "Secrets Manager ARN for the Mattermost database password."
  value       = aws_secretsmanager_secret.mattermost_db_password.arn
}

output "postgres_admin_password_secret_arn" {
  description = "Secrets Manager ARN for the Postgres admin password."
  value       = aws_secretsmanager_secret.postgres_admin_password.arn
}

output "mattermost_site_secret_arn" {
  description = "Secrets Manager ARN for the Mattermost site/app secret."
  value       = aws_secretsmanager_secret.mattermost_site_secret.arn
}

output "openldap_admin_password_secret_arn" {
  description = "Secrets Manager ARN for the OpenLDAP admin password."
  value       = aws_secretsmanager_secret.openldap_admin_password.arn
}

output "openldap_bind_password_secret_arn" {
  description = "Secrets Manager ARN for the OpenLDAP read-only bind password."
  value       = aws_secretsmanager_secret.openldap_bind_password.arn
}

output "nginx_backend_tls_certificate_secret_arn" {
  description = "Secrets Manager ARN for the Nginx backend TLS certificate."
  value       = aws_secretsmanager_secret.nginx_backend_tls_certificate.arn
}

output "nginx_backend_tls_private_key_secret_arn" {
  description = "Secrets Manager ARN for the Nginx backend TLS private key."
  value       = aws_secretsmanager_secret.nginx_backend_tls_private_key.arn
}

output "mattermost_license_secret_arn" {
  description = "Secrets Manager ARN for the optional Mattermost license secret."
  value       = try(aws_secretsmanager_secret.mattermost_license[0].arn, null)
}
