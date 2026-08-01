# ============================================================
# app/frontend/frontend.pkr.hcl
# Packer template for a mock Frontend application AMI.
# Provisioner is a structural placeholder only — no real app code.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=frontend-v2.pkrvars.hcl \
#     frontend.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

# ----------------------------
# Variables — common
# ----------------------------
variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# ----------------------------
# Variables — version-specific
# ----------------------------
variable "app_version" {
  type        = string
  description = "Application version label (e.g. v2.0.0)"
}

variable "source_ami" {
  type        = string
  description = "Middleware or base AMI ID to build on top of"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

variable "output_ami_name" {
  type        = string
  description = "Name for the output AMI"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "frontend" {
  region        = var.aws_region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name       = var.output_ami_name
    App        = "frontend"
    AppVersion = var.app_version
    Layer      = "app"
    ManagedBy  = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "app-frontend-${var.app_version}"
  sources = ["source.amazon-ebs.frontend"]

  provisioner "shell" {
    inline = [
      "echo '==> Frontend ${var.app_version} provisioning started'",
      "",
      "# --- Install runtime dependencies ---",
      "# sudo dnf install -y nodejs npm",
      "",
      "# --- Pull application artifact ---",
      "# aws s3 cp s3://<BUCKET>/frontend-${var.app_version}.tar.gz /tmp/",
      "# sudo tar -xzf /tmp/frontend-${var.app_version}.tar.gz -C /opt/frontend",
      "",
      "# --- Configure reverse proxy (e.g. Nginx) ---",
      "# sudo cp /tmp/nginx-frontend.conf /etc/nginx/conf.d/frontend.conf",
      "# sudo systemctl reload nginx",
      "",
      "# --- Health check ---",
      "# curl -f http://localhost/ || exit 1",
      "",
      "echo '==> Frontend ${var.app_version} provisioning placeholder complete'",
    ]
  }
}
