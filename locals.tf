locals {
  namespace = "${random_id.main.hex}"
  fqdn = "${format("%s-%s.%s", "resume", local.namespace, var.domain_name)}"
}