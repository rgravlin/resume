resource "aws_cloudwatch_log_group" "main" {
  name          = "${local.namespace}"

  tags = {
    namespace   = "${local.namespace}"
  }
}