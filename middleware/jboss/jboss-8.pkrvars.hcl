# middleware/jboss/jboss-8.pkrvars.hcl
# Red Hat JBoss EAP 8.0 — latest supported

middleware_version = "8.0"
hcp_source_bucket  = "base-rhel-9"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-jboss-8.0-{{timestamp}}"
