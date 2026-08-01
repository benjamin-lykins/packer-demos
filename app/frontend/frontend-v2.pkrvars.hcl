# app/frontend/frontend-v2.pkrvars.hcl
# Frontend application — v2 (current)

app_name           = "frontend"
app_version        = "v2.0.0"
hcp_source_bucket  = "middleware-nginx-1-27"
ssh_username       = "ubuntu"
output_ami_name    = "app-frontend-v2.0.0-{{timestamp}}"
