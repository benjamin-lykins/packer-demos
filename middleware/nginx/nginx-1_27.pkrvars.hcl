# middleware/nginx/nginx-1_27.pkrvars.hcl
# Nginx 1.27 — latest stable

middleware_name    = "nginx"
middleware_version = "1.27"
hcp_source_bucket  = "base-ubuntu-24-04"
ssh_username       = "ubuntu"
output_ami_name    = "middleware-nginx-1.27-{{timestamp}}"
