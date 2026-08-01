# app/worker/worker-v2.pkrvars.hcl
# Worker application — v2 (current)

app_name           = "worker"
app_version        = "v2.0.0"
hcp_source_bucket  = "middleware-tomcat-11-0"
ssh_username       = "ec2-user"
output_ami_name    = "app-worker-v2.0.0-{{timestamp}}"
