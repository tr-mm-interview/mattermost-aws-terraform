variable "project" {
  description = "Project name used for resource naming."
  type        = string
  default     = "mattermost"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "interview"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "Local AWS CLI profile Terraform should use."
  type        = string
  default     = "Tom"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "tom"
}

variable "ansible_ssm_bucket_name" {
  description = "Optional globally unique S3 bucket name for Ansible SSM connection module transfer. Defaults to a deterministic account-scoped name."
  type        = string
  default     = null
}

variable "ansible_deploy_role_names" {
  description = "Optional IAM role names for local or CI deploy identities that should receive permissions to run Ansible through SSM."
  type        = list(string)
  default     = []
}

variable "ubuntu_ami_ssm_parameter_name" {
  description = "Public SSM parameter name for the Ubuntu LTS AMI ID used by the Docker host."
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "docker_host_subnet_az" {
  description = "Availability Zone key from aws_subnet.public where the single Docker host and attached EBS volume should be created."
  type        = string
  default     = "eu-west-2a"

  validation {
    condition     = can(regex("^eu-west-2[a-c]$", var.docker_host_subnet_az))
    error_message = "docker_host_subnet_az must be one of the London Availability Zone keys, for example eu-west-2a."
  }
}

variable "docker_host_instance_type" {
  description = "EC2 instance type for the Docker host. t3.small is a cost-effective demo size."
  type        = string
  default     = "t3.small"
}

variable "docker_host_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring for the Docker host."
  type        = bool
  default     = false
}

variable "docker_host_root_volume_size_gb" {
  description = "Root EBS volume size in GiB for the Docker host."
  type        = number
  default     = 20

  validation {
    condition     = var.docker_host_root_volume_size_gb >= 8
    error_message = "docker_host_root_volume_size_gb must be at least 8 GiB."
  }
}

variable "nlb_https_ingress_cidr_blocks" {
  description = "IPv4 CIDR blocks allowed to reach HTTPS on the public Network Load Balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.nlb_https_ingress_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "nlb_https_ingress_cidr_blocks must contain valid IPv4 CIDR blocks."
  }
}

variable "mattermost_hostname" {
  description = "Fully qualified DNS hostname for the Mattermost demo, for example mattermost.example.com."
  type        = string
}

variable "route53_zone_name" {
  description = "Public Route 53 hosted zone name that contains the Mattermost hostname, for example example.com."
  type        = string
}

variable "acm_certificate_arn" {
  description = "Optional existing ACM certificate ARN for the NLB TLS listener. Leave null to create and DNS-validate one for mattermost_hostname."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.acm_certificate_arn == null || can(regex("^arn:aws[a-zA-Z-]*:acm:", var.acm_certificate_arn))
    error_message = "acm_certificate_arn must be null or a valid ACM certificate ARN."
  }
}

variable "nlb_health_check_path" {
  description = "HTTPS health check path served by Nginx on the Docker host."
  type        = string
  default     = "/healthz"
}

variable "create_mattermost_license_secret" {
  description = "Create an optional Secrets Manager container for a Mattermost license. Not required for the first deployment."
  type        = bool
  default     = false
}

variable "efs_performance_mode" {
  description = "Performance mode for the Docker persistent storage EFS file system."
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "efs_performance_mode must be either generalPurpose or maxIO."
  }
}

variable "efs_throughput_mode" {
  description = "Throughput mode for the Docker persistent storage EFS file system."
  type        = string
  default     = "elastic"

  validation {
    condition     = contains(["bursting", "elastic"], var.efs_throughput_mode)
    error_message = "efs_throughput_mode must be either bursting or elastic."
  }
}

variable "efs_transition_to_ia" {
  description = "Lifecycle transition policy for moving EFS files to infrequent access."
  type        = string
  default     = "AFTER_30_DAYS"

  validation {
    condition = contains([
      "AFTER_1_DAY",
      "AFTER_7_DAYS",
      "AFTER_14_DAYS",
      "AFTER_30_DAYS",
      "AFTER_60_DAYS",
      "AFTER_90_DAYS",
    ], var.efs_transition_to_ia)
    error_message = "efs_transition_to_ia must be a valid EFS transition_to_ia value."
  }
}

variable "efs_backup_enabled" {
  description = "Enable AWS Backup automatic backups for the Docker persistent storage EFS file system."
  type        = bool
  default     = true
}

variable "efs_mount_path" {
  description = "Mount path for the shared Docker persistent storage EFS file system on the Docker host."
  type        = string
  default     = "/mnt/docker-data"
}
