resource "aws_ecs_cluster" "main" {
  name = "${local.namespace}"
  tags = {
    namespace = "${local.namespace}"
  }
}

data "template_file" "task-website" {
  template = "${file("${path.module}/templates/website.tmpl")}"
  vars {
    CONFIG_CONTAINER    = "${format(var.ecr, var.account, "dbag.tech", "resume")}"
    CONFIG_LOG_GROUP    = "${local.namespace}"
    CONFIG_LOG_REGION   = "${var.region}"
    CONFIG_LOG_PREFIX   = "${var.cloudwatch_log_prefix}"
  }
}

resource "aws_ecs_task_definition" "website" {
  family                = "website"
  container_definitions = "${data.template_file.task-website.rendered}"
  depends_on            = ["data.template_file.task-website"]

  tags = {
    namespace           = "${local.namespace}"
  }
}

resource "aws_ecs_service" "website" {
  name                  = "website"
  desired_count         = "${var.website_count}"
  task_definition       = "${aws_ecs_task_definition.website.arn}"
  cluster               = "${local.namespace}"

  load_balancer {
    container_name = "website"
    container_port = 443
    target_group_arn = "${aws_lb_target_group.website.arn}"
  }

  tags = {
    namespace           = "${local.namespace}"
  }

  depends_on            = ["aws_ecs_cluster.main", "aws_ecs_task_definition.website", "aws_lb_listener_rule.resume"]
}

resource "aws_lb_target_group" "website" {
  name = "website-${local.namespace}"
  port = 443
  protocol = "HTTPS"
  vpc_id = "${aws_vpc.main.id}"

  health_check {
    path = "/"
    matcher = "200"
    protocol = "HTTPS"
  }

}

resource "aws_lb_listener_rule" "resume" {
  listener_arn = "${aws_lb_listener.main.arn}"

  action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.website.arn}"
  }

  condition {
    field = "host-header"
    values = ["${format("%s-%s.%s", "resume", local.namespace, var.domain_name)}"]
  }
}