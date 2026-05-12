locals {
  name_prefix = "${var.project}-${var.environment}"

  create_acm_certificate = var.acm_certificate_arn == null
  nlb_certificate_arn    = local.create_acm_certificate ? aws_acm_certificate.mattermost[0].arn : var.acm_certificate_arn
  ansible_ssm_bucket     = coalesce(var.ansible_ssm_bucket_name, "${local.name_prefix}-ansible-ssm-${data.aws_caller_identity.current.account_id}")

  default_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}
