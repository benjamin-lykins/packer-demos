# ============================================================
# middleware/weblogic/weblogic.pkr.hcl
# Packer template for Oracle WebLogic middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=weblogic-14.pkrvars.hcl \
#     weblogic.pkr.hcl
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
  default = "t3.medium"
}

# ----------------------------
# Variables — version-specific
# ----------------------------
variable "middleware_version" {
  type        = string
  description = "WebLogic version label (e.g. 14.1.1)"
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
  bucket_name         = var.hcp_source_bucket
  platform            = "aws"
  region              = var.aws_region
  channel_name        = "latest"
}

# ----------------------------
# Source block
# ----------------------------
source "amazon-ebs" "weblogic" {
  region        = var.aws_region
  source_ami    = data.hcp-packer-artifact.base.external_identifier
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = "WebLogic"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-weblogic-${var.middleware_version}"

  hcp_packer_registry {
    bucket_name = "middleware-weblogic-${replace(var.middleware_version, ".", "-")}"
    description = "Oracle WebLogic ${var.middleware_version} middleware image"
    bucket_labels = {
      "layer"      = "middleware"
      "middleware" = "weblogic"
    }
  }

  sources = ["source.amazon-ebs.weblogic"]

  provisioner "shell" {
    inline = [
      "echo '==> WebLogic ${var.middleware_version} provisioning started'",
      "",
      "# --- Java (prerequisite) ---",
      "# sudo dnf install -y java-11-openjdk java-11-openjdk-devel",
      "",
      "# --- Download WebLogic installer ---",
      "# wget -O /tmp/fmw_weblogic.jar <WEBLOGIC_INSTALLER_URL>",
      "",
      "# --- Run silent install ---",
      "# java -jar /tmp/fmw_weblogic.jar -silent -responseFile /tmp/weblogic-response.rsp",
      "",
      "# --- Configure domain ---",
      "# /u01/oracle/middleware/oracle_common/common/bin/wlst.sh /tmp/create-domain.py",
      "",
      "echo '==> WebLogic ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
