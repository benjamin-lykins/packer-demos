# middleware/tomcat/tomcat-11.pkrvars.hcl
# Apache Tomcat 11.0 — latest supported

middleware_version = "11.0"
hcp_source_bucket  = "base-ubuntu-24"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-tomcat-11.0-{{timestamp}}"
