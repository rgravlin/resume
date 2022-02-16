resource "aws_iam_role" "ecs" {
  name = "ecs-${local.namespace}"
  path = "/"

  assume_role_policy = "${data.template_file.trust-ec2-sts.rendered}"

  tags = {
    Name = "ecs-${local.namespace}"
    namespace = "${local.namespace}"
  }
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-${local.namespace}"
  role = "${aws_iam_role.ecs.name}"

  depends_on = [aws_iam_role.ecs]
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"

  depends_on = [aws_iam_role.ecs]
}

data "template_file" "trust-ec2-sts" {
  template = "${file("${path.module}/templates/iam_ec2_sts.tmpl")}"
}