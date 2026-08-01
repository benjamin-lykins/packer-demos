# ============================================================
# middleware/jboss/jboss.pkr.hcl
# Packer template for Red Hat JBoss EAP middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=jboss-8.pkrvars.hcl \
#     jboss.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }

  hcp_packer_registry {
    bucket_name = "middleware-jboss-${replace(var.middleware_version, ".", "-")}"
    description = "JBoss EAP ${var.middleware_version} middleware image"
    bucket_labels = {
      "layer"      = "middleware"
      "middleware" = "jboss"
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
  description = "JBoss EAP version label (e.g. 8.0)"
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
source "amazon-ebs" "jboss" {
  region                 = var.aws_region
  skip_region_validation = true
  source_ami             = data.hcp-packer-artifact.base.external_identifier
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = "JBoss"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-jboss-${var.middleware_version}"

  sources = ["source.amazon-ebs.jboss"]

  provisioner "shell" {
    inline = [
      "echo '==> JBoss EAP ${var.middleware_version} provisioning started'",
      "",
      "# --- Java (prerequisite) ---",
      "# sudo dnf install -y java-11-openjdk java-11-openjdk-devel",
      "",
      "# --- Download JBoss EAP zip ---",
      "# wget -O /tmp/jboss-eap.zip <JBOSS_EAP_DOWNLOAD_URL>",
      "",
      "# --- Extract to install directory ---",
      "# sudo unzip /tmp/jboss-eap.zip -d /opt/",
      "# sudo ln -s /opt/jboss-eap-${var.middleware_version} /opt/jboss",
      "",
      "# --- Create admin user ---",
      "# sudo /opt/jboss/bin/add-user.sh -u admin -p <PASSWORD> -s",
      "",
      "# --- Enable and start service ---",
      "# sudo systemctl enable jboss && sudo systemctl start jboss",
      "",
      "echo '==> JBoss EAP ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
