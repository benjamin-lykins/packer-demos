# ============================================================
# base/rocky/rocky.pkr.hcl
# Packer template for Rocky Linux base AMI.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=rocky-9.pkrvars.hcl \
#     rocky.pkr.hcl
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
  description = "Human-readable OS version label (e.g. 9)"
}

variable "source_ami" {
  type        = string
  description = "Source AMI ID to build from (pinned per version in pkrvars file)"
}

variable "ssh_username" {
  type    = string
  default = "rocky"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "rocky" {
  region                      = var.aws_region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  ami_name                    = "base-rocky-${var.os_version}-{{timestamp}}"
  ami_description = "Base Rocky Linux ${var.os_version} image"

  tags = {
    Name      = "base-rocky-${var.os_version}"
    OS        = "Rocky"
    OSVersion = var.os_version
    Layer     = "base"
    ManagedBy = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "base-rocky-${var.os_version}"

  hcp_packer_registry {
    bucket_name = "base-rocky-${var.os_version}"
    description = "Base Rocky Linux ${var.os_version} image"
    bucket_labels = {
      "layer" = "base"
      "os"    = "rocky"
    }
  }

  sources = ["source.amazon-ebs.rocky"]

  provisioner "shell" {
    inline = [
      "echo '==> Base Rocky Linux ${var.os_version} provisioning started'",
      "sudo dnf update -y",
      "echo '==> Base provisioning complete'",
    ]
  }
}
