resource "aws_route53_record" "lb" {
  zone_id = "Z3BTN42YJBA9UK"
  name    = "${format("%s-%s", "resume", local.namespace)}"
  type    = "A"

  alias {
    name                   = "${aws_lb.main.dns_name}"
    zone_id                = "${aws_lb.main.zone_id}"
    evaluate_target_health = true
  }
}
