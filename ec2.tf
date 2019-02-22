resource "aws_key_pair" "main" {
  key_name               = "main-${local.namespace}"
  public_key             = "${var.ssh_pubkey}"
}

resource "aws_instance" "ecs" {
  ami                    = "${var.instance_ami}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}","${aws_security_group.allow_egress.id}","${aws_security_group.allow_sg.id}"]
  subnet_id              = "${aws_subnet.primary.id}"
  key_name               = "${aws_key_pair.main.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.ecs.name}"
  user_data_base64       = "${base64encode(data.template_file.user-data.rendered)}"

  tags = {
    Name                 = "${local.fqdn}"
    namespace            = "${local.namespace}"
  }
}

data "template_file" "user-data" {
  template = "${file("${path.module}/templates/userdata.tmpl")}"
  vars {
    CONFIG_CLUSTER = "${local.namespace}"
  }
}
