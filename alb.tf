resource "aws_lb_target_group" "blackhole" {
  name        = "blackhole-${local.namespace}"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_lb" "main" {
  name               = "${replace(local.namespace, ".", "-")}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_http.id}","${aws_security_group.allow_sg.id}","${aws_security_group.allow_egress.id}"]
  subnets            = ["${aws_subnet.primary.id}","${aws_subnet.secondary.id}"]

  tags = {
    namespace = "${local.namespace}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_lb_listener" "http-to-https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.blackhole.arn}"
  }

}
