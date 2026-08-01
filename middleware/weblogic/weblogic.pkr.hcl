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

variable "source_ami" {
  type        = string
  description = "Base AMI ID to build on top of (output of a base layer build)"
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
# Source block
# ----------------------------
source "amazon-ebs" "weblogic" {
  region        = var.aws_region
  source_ami    = var.source_ami
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
