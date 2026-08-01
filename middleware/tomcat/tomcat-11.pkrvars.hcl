# middleware/tomcat/tomcat-11.pkrvars.hcl
# Apache Tomcat 11.0 — latest supported

middleware_version = "11.0"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-tomcat-11.0-{{timestamp}}"
