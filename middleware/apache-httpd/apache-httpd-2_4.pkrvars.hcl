# middleware/apache-httpd/apache-httpd-2_4.pkrvars.hcl
# Apache HTTPD 2.4 — latest supported

middleware_version = "2.4"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-apache-httpd-2.4-{{timestamp}}"
