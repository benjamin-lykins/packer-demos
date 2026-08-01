# ============================================================
# app/backend/backend.pkr.hcl
# Packer template for a mock Backend application AMI.
# Provisioner is a structural placeholder only — no real app code.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=backend-v2.pkrvars.hcl \
#     backend.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    hcp = {
      source  = "github.com/hashicorp/hcp"
      version = "~> 0.1"
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
  default = "t3.small"
}

# ----------------------------
# Variables — version-specific
# ----------------------------
variable "app_version" {
  type        = string
  description = "Application version label (e.g. v2.0.0)"
}

variable "hcp_source_bucket" {
  type        = string
  description = "HCP Packer bucket name of the middleware image to build on top of"
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
# HCP Packer source AMI lookup
# ----------------------------
data "hcp-packer-artifact" "middleware" {
  bucket_name         = var.hcp_source_bucket
  platform            = "aws"
  region              = var.aws_region
  channel_name        = "latest"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "backend" {
  region        = var.aws_region
  source_ami    = data.hcp-packer-artifact.middleware.external_identifier
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name       = var.output_ami_name
    App        = "backend"
    AppVersion = var.app_version
    Layer      = "app"
    ManagedBy  = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "app-backend-${var.app_version}"

  hcp_packer_registry {
    bucket_name = "app-backend-${replace(var.app_version, ".", "-")}"
    description = "Backend application ${var.app_version} image"
    bucket_labels = {
      "layer" = "app"
      "app"   = "backend"
    }
  }

  sources = ["source.amazon-ebs.backend"]

  provisioner "shell" {
    inline = [
      "echo '==> Backend ${var.app_version} provisioning started'",
      "",
      "# --- Install runtime dependencies ---",
      "# sudo dnf install -y java-17-openjdk",
      "",
      "# --- Pull application artifact ---",
      "# aws s3 cp s3://<BUCKET>/backend-${var.app_version}.jar /opt/backend/app.jar",
      "",
      "# --- Deploy systemd service unit ---",
      "# sudo cp /tmp/backend.service /etc/systemd/system/backend.service",
      "# sudo systemctl daemon-reload",
      "# sudo systemctl enable backend && sudo systemctl start backend",
      "",
      "# --- Health check ---",
      "# curl -f http://localhost:8080/health || exit 1",
      "",
      "echo '==> Backend ${var.app_version} provisioning placeholder complete'",
    ]
  }
}
