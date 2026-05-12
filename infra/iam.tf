data "aws_iam_policy_document" "docker_host_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "docker_host" {
  name               = "${local.name_prefix}-docker-host-role"
  assume_role_policy = data.aws_iam_policy_document.docker_host_assume_role.json

  tags = {
    Name      = "${local.name_prefix}-docker-host-role"
    Component = "docker-host"
  }
}

resource "aws_iam_role_policy_attachment" "docker_host_ssm" {
  role       = aws_iam_role.docker_host.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "docker_host_cloudwatch" {
  role       = aws_iam_role.docker_host.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "docker_host_secrets" {
  statement {
    sid = "ReadDockerHostSecrets"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]

    resources = local.docker_host_secret_arns
  }
}

resource "aws_iam_policy" "docker_host_secrets" {
  name        = "${local.name_prefix}-docker-host-secrets-read"
  description = "Allow the Docker host to read only required Secrets Manager secrets."
  policy      = data.aws_iam_policy_document.docker_host_secrets.json

  tags = {
    Name      = "${local.name_prefix}-docker-host-secrets-read"
    Component = "docker-host"
  }
}

resource "aws_iam_role_policy_attachment" "docker_host_secrets" {
  role       = aws_iam_role.docker_host.name
  policy_arn = aws_iam_policy.docker_host_secrets.arn
}

data "aws_iam_policy_document" "docker_host_ansible_ssm_bucket" {
  statement {
    sid = "ListAnsibleSsmBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.ansible_ssm.arn]
  }

  statement {
    sid = "UseAnsibleSsmTransferObjects"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.ansible_ssm.arn}/*"]
  }
}

resource "aws_iam_policy" "docker_host_ansible_ssm_bucket" {
  name        = "${local.name_prefix}-docker-host-ansible-ssm-s3"
  description = "Allow the Docker host to use the Ansible SSM transfer bucket."
  policy      = data.aws_iam_policy_document.docker_host_ansible_ssm_bucket.json

  tags = {
    Name      = "${local.name_prefix}-docker-host-ansible-ssm-s3"
    Component = "docker-host"
  }
}

resource "aws_iam_role_policy_attachment" "docker_host_ansible_ssm_bucket" {
  role       = aws_iam_role.docker_host.name
  policy_arn = aws_iam_policy.docker_host_ansible_ssm_bucket.arn
}

data "aws_iam_policy_document" "ansible_deployer" {
  statement {
    sid = "DiscoverDockerHostInstances"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeTags",
      "ssm:DescribeInstanceInformation",
    ]

    resources = ["*"]
  }

  statement {
    sid = "RunSsmSessions"

    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:ResumeSession",
      "ssm:StartSession",
      "ssm:TerminateSession",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ListAnsibleSsmBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.ansible_ssm.arn]
  }

  statement {
    sid = "UseAnsibleSsmTransferObjects"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.ansible_ssm.arn}/*"]
  }
}

resource "aws_iam_policy" "ansible_deployer" {
  name        = "${local.name_prefix}-ansible-deployer"
  description = "Allow a deploy identity to discover EC2 hosts and run Ansible through AWS SSM."
  policy      = data.aws_iam_policy_document.ansible_deployer.json

  tags = {
    Name      = "${local.name_prefix}-ansible-deployer"
    Component = "ansible-ssm"
  }
}

resource "aws_iam_role_policy_attachment" "ansible_deployer" {
  for_each = toset(var.ansible_deploy_role_names)

  role       = each.value
  policy_arn = aws_iam_policy.ansible_deployer.arn
}

resource "aws_iam_instance_profile" "docker_host" {
  name = "${local.name_prefix}-docker-host-profile"
  role = aws_iam_role.docker_host.name

  tags = {
    Name      = "${local.name_prefix}-docker-host-profile"
    Component = "docker-host"
  }
}
