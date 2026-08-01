# middleware/weblogic/weblogic-14.pkrvars.hcl
# Oracle WebLogic 14.1.1 — latest supported

middleware_version = "14.1.1"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-weblogic-14.1.1-{{timestamp}}"
