# middleware/nginx/nginx-1_26.pkrvars.hcl
# Nginx 1.26 — previous stable

middleware_version = "1.26"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-nginx-1.26-{{timestamp}}"
