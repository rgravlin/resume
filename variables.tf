variable "region"                { default = "" }
variable "ecr"                   { default = "%s.dkr.ecr.us-east-1.amazonaws.com/%s:%s" }
variable "account"               { default = "" }
variable "instance_type"         { default = "t2.small" }
variable "instance_ami"          { default = "ami-0796380bc6e51157f" }
variable "website_count"         { default = 1 }
variable "domain_name"           { default = "" }
variable "cloudwatch_log_prefix" { default = "" }
variable "ssh_pubkey"            { default = "" }
variable "ssl_arn"               { default = "" }
variable "route53_zoneid"        { default = "" }
