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

variable "ami_name_filter" {
  type        = string
  description = "Glob pattern to locate the source Rocky Linux AMI"
}

variable "ami_owner_id" {
  type        = string
  description = "AWS account ID of the AMI publisher"
  default     = "792107900819" # Rocky Linux official
}

variable "ssh_username" {
  type    = string
  default = "rocky"
}

# ----------------------------
# Data source — resolve latest matching AMI
# ----------------------------
data "amazon-ami" "rocky" {
  region = var.aws_region
  owners = [var.ami_owner_id]

  filters = {
    name                = var.ami_name_filter
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }

  most_recent = true
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "rocky" {
  region                      = var.aws_region
  source_ami                  = data.amazon-ami.rocky.id
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
  sources = ["source.amazon-ebs.rocky"]

  provisioner "shell" {
    inline = [
      "echo '==> Base Rocky Linux ${var.os_version} provisioning started'",
      "sudo dnf update -y",
      "echo '==> Base provisioning complete'",
    ]
  }
}
