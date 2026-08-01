# middleware/tomcat/tomcat-10.pkrvars.hcl
# Apache Tomcat 10.1 — previous supported

middleware_name    = "tomcat"
middleware_version = "10.1"
hcp_source_bucket  = "base-ubuntu-24-04"
ssh_username       = "ubuntu"
output_ami_name    = "middleware-tomcat-10.1-{{timestamp}}"
