resource "aws_acm_certificate" "mattermost" {
  count = local.create_acm_certificate ? 1 : 0

  domain_name       = var.mattermost_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = "${local.name_prefix}-mattermost-cert"
    Component = "certificate"
  }
}

resource "aws_route53_record" "mattermost_certificate_validation" {
  for_each = local.create_acm_certificate ? {
    for option in aws_acm_certificate.mattermost[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  } : {}

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.mattermost.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "mattermost" {
  count = local.create_acm_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.mattermost[0].arn
  validation_record_fqdns = [for record in aws_route53_record.mattermost_certificate_validation : record.fqdn]
}
