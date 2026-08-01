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
source "amazon-ebs" "nginx" {
  region        = var.aws_region
  source_ami    = var.source_ami
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
