# middleware/apache-httpd/apache-httpd-2_2.pkrvars.hcl
# Apache HTTPD 2.2 — previous supported

middleware_version = "2.2"
hcp_source_bucket  = "base-ubuntu-24"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-apache-httpd-2.2-{{timestamp}}"
