# middleware/tomcat/tomcat-11.pkrvars.hcl
# Apache Tomcat 11.0 — latest supported

middleware_name    = "tomcat"
middleware_version = "11.0"
hcp_source_bucket  = "base-ubuntu-24-04"
ssh_username       = "ubuntu"
output_ami_name    = "middleware-tomcat-11.0-{{timestamp}}"
