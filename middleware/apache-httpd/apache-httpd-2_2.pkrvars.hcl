# middleware/apache-httpd/apache-httpd-2_2.pkrvars.hcl
# Apache HTTPD 2.2 — previous supported

middleware_version = "2.2"
source_ami         = "ami-0placeholder000001" # Replace with output AMI ID from base layer build
ssh_username       = "ec2-user"
output_ami_name    = "middleware-apache-httpd-2.2-{{timestamp}}"
