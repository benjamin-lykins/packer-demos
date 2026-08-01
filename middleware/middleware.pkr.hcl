# ============================================================
# middleware/middleware.pkr.hcl
# Single Packer template for all middleware AMIs.
#
# Build:
#   packer build \
#     -var-file=../common.pkrvars.hcl \
#     -var-file=apache-httpd/apache-httpd-2_4.pkrvars.hcl \
#     middleware.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

hcp_packer_registry {
  bucket_name = "middleware-${var.middleware_name}-${replace(var.middleware_version, ".", "-")}"
  description = "${var.middleware_name} ${var.middleware_version} middleware image"
  bucket_labels = {
    "layer"      = "middleware"
    "middleware" = var.middleware_name
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
variable "middleware_name" {
  type        = string
  description = "Middleware name label used in bucket/AMI names (e.g. apache-httpd, nginx, tomcat)"
}

variable "middleware_version" {
  type        = string
  description = "Middleware version label (e.g. 2.4, 1.27, 11.0)"
}

variable "hcp_source_bucket" {
  type        = string
  description = "HCP Packer bucket name of the base image to build on top of"
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
data "hcp-packer-artifact" "base" {
  bucket_name  = var.hcp_source_bucket
  platform     = "aws"
  region       = var.aws_region
  channel_name = "latest"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "middleware" {
  region                 = var.aws_region
  skip_region_validation = true
  source_ami             = data.hcp-packer-artifact.base.external_identifier
  instance_type          = var.instance_type
  ssh_username           = var.ssh_username
  vpc_id                 = var.vpc_id
  subnet_id              = var.subnet_id
  ami_name               = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = var.middleware_name
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-${var.middleware_name}-${var.middleware_version}"
  sources = ["source.amazon-ebs.middleware"]

  provisioner "shell" {
    inline = [
      "echo '==> ${var.middleware_name} ${var.middleware_version} provisioning started'",
      "echo '==> ${var.middleware_name} ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
