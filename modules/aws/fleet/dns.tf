resource "aws_route53_record" "fleet_domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain}.${var.route53_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.fleet_alb.dns_name
    zone_id                = aws_lb.fleet_alb.zone_id
    evaluate_target_health = true
  }
}