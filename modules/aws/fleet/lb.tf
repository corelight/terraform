#trivy:ignore:AVD-AWS-0053 ALB is intentionally public to allow Fleet web UI and API access. Access is secured via security groups (alb_https_ingress_cidr_blocks, alb_api_ingress_cidr_blocks) and HTTPS with TLS 1.2+.
resource "aws_lb" "fleet_alb" {
  name               = var.fleet_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [local.alb_sg_id]

  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.fleet_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # if certificate_arn is not provided, it will default to an empty string. Pass it in only if you have an ACM certificate.
  certificate_arn = var.certificate_arn != "" ? var.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fleet_tg.arn
  }
}

resource "aws_lb_listener" "https_1443" {
  load_balancer_arn = aws_lb.fleet_alb.arn
  port              = 1443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # if certificate_arn is not provided, it will default to an empty string. Pass it in only if you have an ACM certificate.
  certificate_arn = var.certificate_arn != "" ? var.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fleet_api_tg.arn
  }
}

resource "aws_lb_target_group" "fleet_tg" {
  name     = var.fleet_lb_target_group_name
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTPS"
    port                = "443"
    path                = "/"
    interval            = 30
    unhealthy_threshold = 5
    healthy_threshold   = 2
    matcher             = "200-399"
    enabled             = true
  }
}

resource "aws_lb_target_group" "fleet_api_tg" {
  name     = "${var.fleet_lb_target_group_name}-api"
  port     = 1443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTPS"
    port                = "1443"
    path                = "/"
    interval            = 30
    unhealthy_threshold = 5
    healthy_threshold   = 2
    matcher             = "404"
    enabled             = true
  }

}

resource "aws_lb_target_group_attachment" "fleet" {
  target_group_arn = aws_lb_target_group.fleet_tg.arn
  target_id        = aws_instance.fleet_instance.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "fleet_api" {
  target_group_arn = aws_lb_target_group.fleet_api_tg.arn
  target_id        = aws_instance.fleet_instance.id
  port             = 1443
}