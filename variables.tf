variable "region"                { default = "us-east-1" }
variable "ecr"                   { default = "%s.dkr.ecr.us-east-1.amazonaws.com/%s:%s" }
variable "account"               { default = "826021588766" }
variable "instance_type"         { default = "t2.small" }
variable "instance_ami"          { default = "ami-0796380bc6e51157f" }
variable "website_count"         { default = 1 }
variable "domain_name"           { default = "dbag.tech" }
variable "cloudwatch_log_prefix" { default = "website" }
variable "ssh_pubkey"            { default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAx6D1jdPodOModRAruuBiKWKTCkWqG8cGorUgzQaH7TpORFXL4GVS6ry3vVo2HCKbeOmE1jPyp34KcCm3bR/PiAbElC5MmHS0h1GDethLo6bf6dUovs6MDu6HbJm0M86YFz5i4d3p2FHDr05Dv+dRRsen4AcnYlycrjpok1q3kB9zY+JgQzbymymDFmOylRh0MTsUivIDKOeN29uyk/utCoulaG4s1kOo9DFhPcfjjdy5CiQ9LPT2lFapmsbMCxrC82BGtnGzgzERIXfNYn1qj921by+yeGLDDUdfDgmSWlva7F67ckRZACIiBZZaEde65OmRrDiRgfDkbuoJZL+eSw== majordb@dbagshirts.com" }
variable "ssl_arn"               { default = "arn:aws:acm:us-east-1:826021588766:certificate/57a6d136-99a8-4204-a214-6a9f9b4956ac" }
