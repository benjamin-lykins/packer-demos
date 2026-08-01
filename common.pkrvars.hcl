# ============================================================
# common.pkrvars.hcl
# Shared AWS variables passed to every packer build via:
#   -var-file=../../common.pkrvars.hcl
# Replace placeholder values with your real AWS environment.
# ============================================================

aws_region    = "us-east-1"
vpc_id        = "vpc-0a582bfb4de4f1cd3"
subnet_id     = "subnet-01ffa53606b87e2ef"
instance_type = "t3.micro"
