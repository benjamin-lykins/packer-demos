# middleware/nginx/nginx-1_27.pkrvars.hcl
# Nginx 1.27 — latest stable

middleware_version = "1.27"
hcp_source_bucket  = "base-ubuntu-24"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-nginx-1.27-{{timestamp}}"
