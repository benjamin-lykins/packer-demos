# middleware/nginx/nginx-1_26.pkrvars.hcl
# Nginx 1.26 — previous stable

middleware_version = "1.26"
hcp_source_bucket  = "base-ubuntu-24"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-nginx-1.26-{{timestamp}}"
