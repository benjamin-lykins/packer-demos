# middleware/apache-httpd/apache-httpd-2_4.pkrvars.hcl
# Apache HTTPD 2.4 — latest supported

middleware_name    = "apache-httpd"
middleware_version = "2.4"
hcp_source_bucket  = "base-ubuntu-24-04"
ssh_username       = "ubuntu"
output_ami_name    = "middleware-apache-httpd-2.4-{{timestamp}}"
