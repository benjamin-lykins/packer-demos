# middleware/websphere/websphere-9.pkrvars.hcl
# IBM WebSphere Application Server 9.0 — latest supported

middleware_version = "9.0"
hcp_source_bucket  = "base-rhel-9"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-websphere-9.0-{{timestamp}}"
