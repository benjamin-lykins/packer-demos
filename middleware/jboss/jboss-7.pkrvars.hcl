# middleware/jboss/jboss-7.pkrvars.hcl
# Red Hat JBoss EAP 7.4 — previous supported

middleware_version = "7.4"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-jboss-7.4-{{timestamp}}"
