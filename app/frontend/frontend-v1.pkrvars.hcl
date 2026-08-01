# app/frontend/frontend-v1.pkrvars.hcl
# Frontend application — v1 (previous)

app_name           = "frontend"
app_version        = "v1.0.0"
hcp_source_bucket  = "middleware-nginx-1-26"
ssh_username       = "ubuntu"
output_ami_name    = "app-frontend-v1.0.0-{{timestamp}}"
