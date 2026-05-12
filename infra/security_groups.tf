resource "aws_security_group" "mattermost_nlb" {
  name        = "${local.name_prefix}-nlb-sg"
  description = "Security group for the public Mattermost Network Load Balancer."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name      = "${local.name_prefix}-nlb-sg"
    Component = "nlb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mattermost_nlb_https" {
  for_each = toset(var.nlb_https_ingress_cidr_blocks)

  security_group_id = aws_security_group.mattermost_nlb.id
  description       = "Allow public HTTPS to the Mattermost NLB."
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Name      = "${local.name_prefix}-nlb-https"
    Component = "nlb"
  }
}

resource "aws_vpc_security_group_egress_rule" "mattermost_nlb_to_docker_host_https" {
  security_group_id            = aws_security_group.mattermost_nlb.id
  description                  = "Allow the Mattermost NLB to reach Nginx TLS on the Docker host."
  referenced_security_group_id = aws_security_group.docker_host.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443

  tags = {
    Name      = "${local.name_prefix}-nlb-to-docker-host-https"
    Component = "nlb"
  }
}

resource "aws_security_group" "docker_host" {
  name        = "${local.name_prefix}-docker-host-sg"
  description = "Security group for the Docker host."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name      = "${local.name_prefix}-docker-host-sg"
    Component = "docker-host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "docker_host_https" {
  security_group_id            = aws_security_group.docker_host.id
  description                  = "Allow HTTPS from the Mattermost NLB to Nginx on the Docker host."
  referenced_security_group_id = aws_security_group.mattermost_nlb.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443

  tags = {
    Name      = "${local.name_prefix}-docker-host-https"
    Component = "docker-host"
  }
}

resource "aws_vpc_security_group_egress_rule" "docker_host_all_ipv4" {
  security_group_id = aws_security_group.docker_host.id
  description       = "Allow outbound IPv4 traffic for package installation, SSM, CloudWatch and Secrets Manager."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name      = "${local.name_prefix}-docker-host-egress-ipv4"
    Component = "docker-host"
  }
}

resource "aws_security_group" "efs" {
  name        = "${local.name_prefix}-efs-sg"
  description = "Security group for the Docker persistent storage EFS file system."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name      = "${local.name_prefix}-efs-sg"
    Component = "efs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs_from_docker_host" {
  security_group_id            = aws_security_group.efs.id
  description                  = "Allow NFS from the Docker host."
  referenced_security_group_id = aws_security_group.docker_host.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049

  tags = {
    Name      = "${local.name_prefix}-efs-nfs-from-docker-host"
    Component = "efs"
  }
}
