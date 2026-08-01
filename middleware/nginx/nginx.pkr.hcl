# ============================================================
# middleware/nginx/nginx.pkr.hcl
# Packer template for Nginx middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=nginx-1_27.pkrvars.hcl \
#     nginx.pkr.hcl
# ============================================================

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }

  hcp_packer_registry {
    bucket_name = "middleware-nginx-${replace(var.middleware_version, ".", "-")}"
    description = "Nginx ${var.middleware_version} middleware image"
    bucket_labels = {
      "layer"      = "middleware"
      "middleware" = "nginx"
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
  description = "Nginx version label (e.g. 1.27)"
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
source "amazon-ebs" "nginx" {
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
    Middleware        = "Nginx"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-nginx-${var.middleware_version}"

  sources = ["source.amazon-ebs.nginx"]

  provisioner "shell" {
    inline = [
      "echo '==> Nginx ${var.middleware_version} provisioning started'",
      "",
      "# --- Add Nginx official repo ---",
      "# sudo tee /etc/yum.repos.d/nginx.repo <<'EOF'",
      "# [nginx-stable]",
      "# name=nginx stable repo",
      "# baseurl=http://nginx.org/packages/centos/$releasever/$basearch/",
      "# gpgcheck=1",
      "# EOF",
      "",
      "# --- Install Nginx ---",
      "# sudo dnf install -y nginx-${var.middleware_version}",
      "",
      "# --- Enable and start ---",
      "# sudo systemctl enable nginx && sudo systemctl start nginx",
      "",
      "echo '==> Nginx ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
