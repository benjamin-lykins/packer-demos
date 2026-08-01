# middleware/tomcat/tomcat-10.pkrvars.hcl
# Apache Tomcat 10.1 — previous supported

middleware_version = "10.1"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-tomcat-10.1-{{timestamp}}"
