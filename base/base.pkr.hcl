# ============================================================
# base/base.pkr.hcl
# Single Packer template for all base OS AMIs.
#
# Build:
#   packer build \
#     -var-file=../common.pkrvars.hcl \
#     -var-file=rhel/rhel-9.pkrvars.hcl \
#     base.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }

  hcp_packer_registry {
    bucket_name = "base-${var.os_name}-${replace(var.os_version, ".", "-")}"
    description = "Base ${var.os_name} ${var.os_version} image"
    bucket_labels = {
      "layer" = "base"
      "os"    = var.os_name
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
variable "os_name" {
  type        = string
  description = "OS name label used in bucket/AMI names (e.g. rhel, ubuntu, debian, rocky)"
}

variable "os_version" {
  type        = string
  description = "Human-readable OS version label (e.g. 9, 24.04, 12)"
}

variable "source_ami" {
  type        = string
  description = "Source AMI ID to build from (pinned per version in pkrvars file)"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for the source AMI (e.g. ec2-user, ubuntu, admin, rocky)"
}

variable "update_cmd" {
  type        = string
  default     = "sudo dnf update -y"
  description = "Package manager update command for the OS (e.g. sudo apt-get update -y)"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "base" {
  region                      = var.aws_region
  skip_region_validation      = true
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  ami_name                    = "base-${var.os_name}-${var.os_version}-{{timestamp}}"
  ami_description             = "Base ${var.os_name} ${var.os_version} image"

  tags = {
    Name      = "base-${var.os_name}-${var.os_version}"
    OS        = var.os_name
    OSVersion = var.os_version
    Layer     = "base"
    ManagedBy = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "base-${var.os_name}-${var.os_version}"
  sources = ["source.amazon-ebs.base"]

  provisioner "shell" {
    inline = [
      "echo '==> Base ${var.os_name} ${var.os_version} provisioning started'",
      var.update_cmd,
      "echo '==> Base provisioning complete'",
    ]
  }
}
