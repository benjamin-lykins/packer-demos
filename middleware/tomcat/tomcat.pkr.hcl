# ============================================================
# middleware/tomcat/tomcat.pkr.hcl
# Packer template for Apache Tomcat middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=tomcat-11.pkrvars.hcl \
#     tomcat.pkr.hcl
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
  default = "t3.micro"
}

# ----------------------------
# Variables — version-specific
# ----------------------------
variable "middleware_version" {
  type        = string
  description = "Tomcat version label (e.g. 11.0)"
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
source "amazon-ebs" "tomcat" {
  region        = var.aws_region
  source_ami    = data.hcp-packer-artifact.base.external_identifier
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = "Tomcat"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-tomcat-${var.middleware_version}"

  hcp_packer_registry {
    bucket_name = "middleware-tomcat-${replace(var.middleware_version, ".", "-")}"
    description = "Apache Tomcat ${var.middleware_version} middleware image"
    bucket_labels = {
      "layer"      = "middleware"
      "middleware" = "tomcat"
    }
  }

  sources = ["source.amazon-ebs.tomcat"]

  provisioner "shell" {
    inline = [
      "echo '==> Tomcat ${var.middleware_version} provisioning started'",
      "",
      "# --- Java (prerequisite) ---",
      "# sudo dnf install -y java-17-openjdk java-17-openjdk-devel",
      "",
      "# --- Download Tomcat ---",
      "# wget -O /tmp/apache-tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-${var.middleware_version}/bin/apache-tomcat-${var.middleware_version}.tar.gz",
      "",
      "# --- Extract and install ---",
      "# sudo tar -xzf /tmp/apache-tomcat.tar.gz -C /opt/",
      "# sudo ln -s /opt/apache-tomcat-${var.middleware_version} /opt/tomcat",
      "",
      "# --- Create systemd service ---",
      "# sudo cp /tmp/tomcat.service /etc/systemd/system/tomcat.service",
      "# sudo systemctl daemon-reload",
      "# sudo systemctl enable tomcat && sudo systemctl start tomcat",
      "",
      "echo '==> Tomcat ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
