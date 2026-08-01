# ============================================================
# base/rhel/rhel.pkr.hcl
# Packer template for Red Hat Enterprise Linux base AMI.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=rhel-9.pkrvars.hcl \
#     rhel.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }

  hcp_packer_registry {
    bucket_name = "base-rhel-${replace(var.os_version, ".", "-")}"
    description = "Base RHEL ${var.os_version} image"
    bucket_labels = {
      "layer" = "base"
      "os"    = "rhel"
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
  default = "ec2-user"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "rhel" {
  region                      = var.aws_region
  skip_region_validation      = true
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  ami_name                    = "base-rhel-${var.os_version}-{{timestamp}}"
  ami_description = "Base RHEL ${var.os_version} image"

  tags = {
    Name      = "base-rhel-${var.os_version}"
    OS        = "RHEL"
    OSVersion = var.os_version
    Layer     = "base"
    ManagedBy = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "base-rhel-${var.os_version}"

  sources = ["source.amazon-ebs.rhel"]

  provisioner "shell" {
    inline = [
      "echo '==> Base RHEL ${var.os_version} provisioning started'",
      "sudo dnf update -y",
      "echo '==> Base provisioning complete'",
    ]
  }
}
