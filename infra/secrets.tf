resource "aws_secretsmanager_secret" "mattermost_db_password" {
  name        = "/${local.name_prefix}/mattermost/db-password"
  description = "Mattermost database user password. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-mattermost-db-password"
    Component = "secrets"
    Service   = "mattermost"
  }
}

resource "aws_secretsmanager_secret" "postgres_admin_password" {
  name        = "/${local.name_prefix}/postgres/admin-password"
  description = "Postgres admin password. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-postgres-admin-password"
    Component = "secrets"
    Service   = "postgres"
  }
}

resource "aws_secretsmanager_secret" "mattermost_site_secret" {
  name        = "/${local.name_prefix}/mattermost/site-secret"
  description = "Mattermost site/app secret. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-mattermost-site-secret"
    Component = "secrets"
    Service   = "mattermost"
  }
}

resource "aws_secretsmanager_secret" "openldap_admin_password" {
  name        = "/${local.name_prefix}/openldap/admin-password"
  description = "OpenLDAP admin password. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-openldap-admin-password"
    Component = "secrets"
    Service   = "openldap"
  }
}

resource "aws_secretsmanager_secret" "openldap_bind_password" {
  name        = "/${local.name_prefix}/openldap/bind-password"
  description = "OpenLDAP read-only bind password. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-openldap-bind-password"
    Component = "secrets"
    Service   = "openldap"
  }
}

resource "aws_secretsmanager_secret" "nginx_backend_tls_certificate" {
  name        = "/${local.name_prefix}/nginx/backend-tls-certificate"
  description = "Nginx backend TLS certificate presented to the NLB target group. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-nginx-backend-tls-certificate"
    Component = "secrets"
    Service   = "nginx"
  }
}

resource "aws_secretsmanager_secret" "nginx_backend_tls_private_key" {
  name        = "/${local.name_prefix}/nginx/backend-tls-private-key"
  description = "Nginx backend TLS private key presented to the NLB target group. Populate manually after Terraform creates the secret container."

  tags = {
    Name      = "${local.name_prefix}-nginx-backend-tls-private-key"
    Component = "secrets"
    Service   = "nginx"
  }
}

resource "aws_secretsmanager_secret" "mattermost_license" {
  count = var.create_mattermost_license_secret ? 1 : 0

  name        = "/${local.name_prefix}/mattermost/license"
  description = "Optional Mattermost license value. Not required for the first deployment."

  tags = {
    Name      = "${local.name_prefix}-mattermost-license"
    Component = "secrets"
    Service   = "mattermost"
    Optional  = "true"
  }
}

locals {
  docker_host_secret_arns = concat(
    [
      aws_secretsmanager_secret.mattermost_db_password.arn,
      aws_secretsmanager_secret.postgres_admin_password.arn,
      aws_secretsmanager_secret.mattermost_site_secret.arn,
      aws_secretsmanager_secret.openldap_admin_password.arn,
      aws_secretsmanager_secret.openldap_bind_password.arn,
      aws_secretsmanager_secret.nginx_backend_tls_certificate.arn,
      aws_secretsmanager_secret.nginx_backend_tls_private_key.arn,
    ],
    aws_secretsmanager_secret.mattermost_license[*].arn,
  )
}
