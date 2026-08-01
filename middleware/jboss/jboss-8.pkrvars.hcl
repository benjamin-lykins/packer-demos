# middleware/jboss/jboss-8.pkrvars.hcl
# Red Hat JBoss EAP 8.0 — latest supported

middleware_version = "8.0"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-jboss-8.0-{{timestamp}}"
