# app/worker/worker-v1.pkrvars.hcl
# Worker application — v1 (previous)

app_version     = "v1.0.0"
source_ami      = "ami-0placeholder000002" # Replace with output AMI ID from middleware layer build
ssh_username    = "ec2-user"
output_ami_name = "app-worker-v1.0.0-{{timestamp}}"
