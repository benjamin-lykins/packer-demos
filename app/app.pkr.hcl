# ============================================================
# app/app.pkr.hcl
# Single Packer template for all application AMIs.
#
# Build:
#   packer build \
#     -var-file=../common.pkrvars.hcl \
#     -var-file=backend/backend-v2.pkrvars.hcl \
#     app.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }

  hcp_packer_registry {
    bucket_name = "app-${var.app_name}-${replace(var.app_version, ".", "-")}"
    description = "${var.app_name} application ${var.app_version} image"
    bucket_labels = {
      "layer" = "app"
      "app"   = var.app_name
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
variable "app_name" {
  type        = string
  description = "Application name label used in bucket/AMI names (e.g. backend, frontend, worker)"
}

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
  bucket_name  = var.hcp_source_bucket
  platform     = "aws"
  region       = var.aws_region
  channel_name = "latest"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "app" {
  region                 = var.aws_region
  skip_region_validation = true
  source_ami             = data.hcp-packer-artifact.middleware.external_identifier
  instance_type          = var.instance_type
  ssh_username           = var.ssh_username
  vpc_id                 = var.vpc_id
  subnet_id              = var.subnet_id
  ami_name               = var.output_ami_name

  tags = {
    Name       = var.output_ami_name
    App        = var.app_name
    AppVersion = var.app_version
    Layer      = "app"
    ManagedBy  = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "app-${var.app_name}-${var.app_version}"
  sources = ["source.amazon-ebs.app"]

  provisioner "shell" {
    inline = [
      "echo '==> ${var.app_name} ${var.app_version} provisioning started'",
      "echo '==> ${var.app_name} ${var.app_version} provisioning placeholder complete'",
    ]
  }
}
