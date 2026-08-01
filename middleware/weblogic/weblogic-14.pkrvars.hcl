# middleware/weblogic/weblogic-14.pkrvars.hcl
# Oracle WebLogic 14.1.1 — latest supported

middleware_name    = "weblogic"
middleware_version = "14.1.1"
hcp_source_bucket  = "base-rhel-9"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-weblogic-14.1.1-{{timestamp}}"
