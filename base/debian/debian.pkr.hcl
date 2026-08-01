# ============================================================
# base/debian/debian.pkr.hcl
# Packer template for Debian base AMI.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=debian-12.pkrvars.hcl \
#     debian.pkr.hcl
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
variable "os_version" {
  type        = string
  description = "Human-readable OS version label (e.g. 12)"
}

variable "source_ami" {
  type        = string
  description = "Source AMI ID to build from (pinned per version in pkrvars file)"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "debian" {
  region                      = var.aws_region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  ami_name                    = "base-debian-${var.os_version}-{{timestamp}}"
  ami_description = "Base Debian ${var.os_version} image"

  tags = {
    Name      = "base-debian-${var.os_version}"
    OS        = "Debian"
    OSVersion = var.os_version
    Layer     = "base"
    ManagedBy = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "base-debian-${var.os_version}"

  hcp_packer_registry {
    bucket_name = "base-debian-${var.os_version}"
    description = "Base Debian ${var.os_version} image"
    bucket_labels = {
      "layer" = "base"
      "os"    = "debian"
    }
  }

  sources = ["source.amazon-ebs.debian"]

  provisioner "shell" {
    inline = [
      "echo '==> Base Debian ${var.os_version} provisioning started'",
      "sudo apt-get update -y",
      "echo '==> Base provisioning complete'",
    ]
  }
}
