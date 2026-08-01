# ============================================================
# base/ubuntu/ubuntu.pkr.hcl
# Packer template for Ubuntu base AMI.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=ubuntu-24.pkrvars.hcl \
#     ubuntu.pkr.hcl
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
# Variables — common (provided via common.pkrvars.hcl)
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
# Variables — version-specific (provided via ubuntu-XX.pkrvars.hcl)
# ----------------------------
variable "os_version" {
  type        = string
  description = "Human-readable OS version label (e.g. 24.04)"
}

variable "source_ami" {
  type        = string
  description = "Source AMI ID to build from (pinned per version in pkrvars file)"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "ubuntu" {
  region                      = var.aws_region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  ami_name                    = "base-ubuntu-${var.os_version}-{{timestamp}}"
  ami_description = "Base Ubuntu ${var.os_version} image"

  tags = {
    Name       = "base-ubuntu-${var.os_version}"
    OS         = "Ubuntu"
    OSVersion  = var.os_version
    Layer      = "base"
    ManagedBy  = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "base-ubuntu-${var.os_version}"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "echo '==> Base Ubuntu ${var.os_version} provisioning started'",
      "sudo apt-get update -y",
      "echo '==> Base provisioning complete'",
    ]
  }
}
