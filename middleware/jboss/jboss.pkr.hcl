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
source "amazon-ebs" "jboss" {
  region        = var.aws_region
  source_ami    = var.source_ami
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
