# middleware/weblogic/weblogic-12.pkrvars.hcl
# Oracle WebLogic 12.2.1 — previous supported

middleware_version = "12.2.1"
hcp_source_bucket  = "base-rhel-8"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-weblogic-12.2.1-{{timestamp}}"
