output "url" {
  value       = "${format("%s%s", "https://", local.fqdn)}"
}
