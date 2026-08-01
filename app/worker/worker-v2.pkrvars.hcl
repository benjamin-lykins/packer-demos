# app/worker/worker-v2.pkrvars.hcl
# Worker application — v2 (current)

app_version     = "v2.0.0"
source_ami      = "ami-0placeholder000002" # Replace with output AMI ID from middleware layer build
ssh_username    = "ec2-user"
output_ami_name = "app-worker-v2.0.0-{{timestamp}}"
