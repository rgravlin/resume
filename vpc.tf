data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block       = "172.16.0.0/19"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.namespace}"
    namespace = "${local.namespace}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${local.namespace}"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "primary" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "172.16.1.0/24"
  map_public_ip_on_launch = true

  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "${format("%s-%s", local.namespace, data.aws_availability_zones.available.names[0])}"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "secondary" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "172.16.2.0/24"
  map_public_ip_on_launch = true

  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${format("%s-%s", local.namespace, data.aws_availability_zones.available.names[1])}"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_route" "route" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"

  depends_on = [aws_internet_gateway.main]
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh-${local.namespace}"
  description = "Allow all inbound ssh traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http-${local.namespace}"
  description = "Allow HTTP traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "allow_egress" {
  name        = "allow_egress-${local.namespace}"
  description = "Allow all egress"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_egress"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "allow_sg" {
  name        = "allow_sg-${local.namespace}"
  description = "Self trusted security group"

  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    self        = true
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "allow_sg"
    namespace = "${local.namespace}"
  }

  depends_on = [aws_vpc.main]
}
