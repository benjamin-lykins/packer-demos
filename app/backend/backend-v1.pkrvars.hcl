# app/backend/backend-v1.pkrvars.hcl
# Backend application — v1 (previous)

app_name           = "backend"
app_version        = "v1.0.0"
hcp_source_bucket  = "middleware-tomcat-10-1"
ssh_username       = "ubuntu"
output_ami_name    = "app-backend-v1.0.0-{{timestamp}}"
