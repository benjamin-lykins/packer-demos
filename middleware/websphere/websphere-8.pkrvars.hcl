# middleware/websphere/websphere-8.pkrvars.hcl
# IBM WebSphere Application Server 8.5 — previous supported

middleware_version = "8.5"
hcp_source_bucket  = "base-rhel-8"
ssh_username       = "ec2-user"
output_ami_name    = "middleware-websphere-8.5-{{timestamp}}"
