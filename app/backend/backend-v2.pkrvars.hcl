# app/backend/backend-v2.pkrvars.hcl
# Backend application — v2 (current)

app_version        = "v2.0.0"
hcp_source_bucket  = "middleware-tomcat-11-0"
ssh_username       = "ec2-user"
output_ami_name    = "app-backend-v2.0.0-{{timestamp}}"
