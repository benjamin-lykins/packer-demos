# app/worker/worker-v1.pkrvars.hcl
# Worker application — v1 (previous)

app_name           = "worker"
app_version        = "v1.0.0"
hcp_source_bucket  = "middleware-tomcat-10-1"
ssh_username       = "ubuntu"
output_ami_name    = "app-worker-v1.0.0-{{timestamp}}"
