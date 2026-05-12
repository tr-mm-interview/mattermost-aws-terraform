resource "aws_lb" "mattermost" {
  name               = "${local.name_prefix}-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.mattermost_nlb.id]
  subnets            = values(aws_subnet.public)[*].id

  enable_deletion_protection = false

  tags = {
    Name      = "${local.name_prefix}-nlb"
    Component = "nlb"
  }
}

resource "aws_lb_target_group" "mattermost" {
  name        = "${local.name_prefix}-tg"
  port        = 443
  protocol    = "TLS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    port                = "traffic-port"
    path                = var.nlb_health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 10
  }

  tags = {
    Name      = "${local.name_prefix}-tg"
    Component = "nlb"
  }
}

resource "aws_lb_target_group_attachment" "docker_host" {
  target_group_arn = aws_lb_target_group.mattermost.arn
  target_id        = aws_instance.docker_host.id
  port             = 443
}

resource "aws_lb_listener" "mattermost_https" {
  depends_on = [aws_acm_certificate_validation.mattermost]

  load_balancer_arn = aws_lb.mattermost.arn
  port              = 443
  protocol          = "TLS"
  certificate_arn   = local.nlb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mattermost.arn
  }

  tags = {
    Name      = "${local.name_prefix}-https-listener"
    Component = "nlb"
  }
}

resource "aws_route53_record" "mattermost" {
  zone_id = data.aws_route53_zone.mattermost.zone_id
  name    = var.mattermost_hostname
  type    = "A"

  alias {
    name                   = aws_lb.mattermost.dns_name
    zone_id                = aws_lb.mattermost.zone_id
    evaluate_target_health = true
  }
}
