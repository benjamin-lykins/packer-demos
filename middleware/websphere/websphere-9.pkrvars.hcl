# middleware/websphere/websphere-9.pkrvars.hcl
# IBM WebSphere Application Server 9.0 — latest supported

middleware_version = "9.0"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-websphere-9.0-{{timestamp}}"
