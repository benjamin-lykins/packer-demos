# middleware/weblogic/weblogic-12.pkrvars.hcl
# Oracle WebLogic 12.2.1 — previous supported

middleware_version = "12.2.1"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-weblogic-12.2.1-{{timestamp}}"
