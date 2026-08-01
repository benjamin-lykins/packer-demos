# middleware/jboss/jboss-7.pkrvars.hcl
# Red Hat JBoss EAP 7.4 — previous supported

middleware_version = "7.4"
hcp_source_bucket  = "base-rhel-8"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-jboss-7.4-{{timestamp}}"
