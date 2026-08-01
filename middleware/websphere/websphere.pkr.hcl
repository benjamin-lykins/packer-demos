# ============================================================
# middleware/websphere/websphere.pkr.hcl
# Packer template for IBM WebSphere middleware AMI.
# Provisioner is a structural placeholder only — no real install.
#
# Build (from this directory):
#   packer build \
#     -var-file=../../common.pkrvars.hcl \
#     -var-file=websphere-9.pkrvars.hcl \
#     websphere.pkr.hcl
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
  description = "WebSphere version label (e.g. 9.0)"
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
source "amazon-ebs" "websphere" {
  region        = var.aws_region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_name      = var.output_ami_name

  tags = {
    Name              = var.output_ami_name
    Middleware        = "WebSphere"
    MiddlewareVersion = var.middleware_version
    Layer             = "middleware"
    ManagedBy         = "packer"
  }
}

# ----------------------------
# Build block
# ----------------------------
build {
  name    = "middleware-websphere-${var.middleware_version}"
  sources = ["source.amazon-ebs.websphere"]

  provisioner "shell" {
    inline = [
      "echo '==> WebSphere ${var.middleware_version} provisioning started'",
      "",
      "# --- Java (prerequisite) ---",
      "# sudo dnf install -y java-11-openjdk java-11-openjdk-devel",
      "",
      "# --- IBM Installation Manager ---",
      "# wget -O /tmp/agent.installer.linux.gtk.x86_64.zip <IBM_IM_URL>",
      "# unzip /tmp/agent.installer.linux.gtk.x86_64.zip -d /tmp/im-install",
      "# sudo /tmp/im-install/installc -acceptLicense -silent",
      "",
      "# --- Install WebSphere Application Server ---",
      "# /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.BASE.v90 \\",
      "#   -repositories <IBM_REPO_URL> \\",
      "#   -installationDirectory /opt/IBM/WebSphere/AppServer \\",
      "#   -acceptLicense",
      "",
      "# --- Create application server profile ---",
      "# /opt/IBM/WebSphere/AppServer/bin/manageprofiles.sh -create -profileName AppSrv01",
      "",
      "echo '==> WebSphere ${var.middleware_version} provisioning placeholder complete'",
    ]
  }
}
