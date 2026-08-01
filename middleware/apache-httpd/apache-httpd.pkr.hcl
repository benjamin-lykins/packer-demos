# ============================================================
# middleware/apache-httpd/apache-httpd.pkr.hcl
# Packer template for Apache HTTPD middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=apache-httpd-2_4.pkrvars.hcl \
#     apache-httpd.pkr.hcl
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
variable "middleware_version" {
  type        = string
  description = "Apache HTTPD version label (e.g. 2.4)"
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
source "amazon-ebs" "apache_httpd" {
  region        = var.aws_region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = "Apache-HTTPD"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-apache-httpd-${var.middleware_version}"
  sources = ["source.amazon-ebs.apache_httpd"]

  provisioner "shell" {
    inline = [
      "echo '==> Apache HTTPD ${var.middleware_version} provisioning started'",
      "",
      "# --- Install Apache HTTPD ---",
      "# sudo dnf install -y httpd",
      "",
      "# --- Install mod_ssl for HTTPS ---",
      "# sudo dnf install -y mod_ssl",
      "",
      "# --- Deploy custom httpd.conf ---",
      "# sudo cp /tmp/httpd.conf /etc/httpd/conf/httpd.conf",
      "",
      "# --- Enable and start ---",
      "# sudo systemctl enable httpd && sudo systemctl start httpd",
      "",
      "echo '==> Apache HTTPD ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
