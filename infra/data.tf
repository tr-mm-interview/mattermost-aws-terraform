data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ubuntu_lts_ami" {
  name = var.ubuntu_ami_ssm_parameter_name
}

data "aws_route53_zone" "mattermost" {
  name         = var.route53_zone_name
  private_zone = false
}
