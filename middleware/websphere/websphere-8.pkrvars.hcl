# middleware/websphere/websphere-8.pkrvars.hcl
# IBM WebSphere Application Server 8.5 — previous supported

middleware_version = "8.5"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-websphere-8.5-{{timestamp}}"
