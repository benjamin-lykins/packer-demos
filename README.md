# Packer Build Pipeline

A structured Packer image pipeline for AWS (`amazon-ebs`) with three layers:

| Layer | Purpose |
|-------|---------|
| **base** | Hardened OS images — Ubuntu, RHEL, Debian, Rocky Linux |
| **middleware** | Runtime platform images built on top of a base AMI — WebLogic, WebSphere, JBoss, Nginx, Apache HTTPD, Tomcat |
| **app** | Application images built on top of a middleware or base AMI — frontend, backend, worker |

---

## Directory Structure

```
packer-demos/
├── common.pkrvars.hcl              # Shared AWS variables (region, VPC, subnet, instance type)
│
├── base/
│   ├── ubuntu/
│   │   ├── ubuntu.pkr.hcl
│   │   ├── ubuntu-24.pkrvars.hcl   # Ubuntu 24.04 LTS — latest
│   │   └── ubuntu-22.pkrvars.hcl   # Ubuntu 22.04 LTS — previous
│   ├── rhel/
│   │   ├── rhel.pkr.hcl
│   │   ├── rhel-9.pkrvars.hcl      # RHEL 9 — latest
│   │   └── rhel-8.pkrvars.hcl      # RHEL 8 — previous
│   ├── debian/
│   │   ├── debian.pkr.hcl
│   │   ├── debian-12.pkrvars.hcl   # Debian 12 Bookworm — latest
│   │   └── debian-11.pkrvars.hcl   # Debian 11 Bullseye — previous
│   └── rocky/
│       ├── rocky.pkr.hcl
│       ├── rocky-9.pkrvars.hcl     # Rocky Linux 9 — latest
│       └── rocky-8.pkrvars.hcl     # Rocky Linux 8 — previous
│
├── middleware/
│   ├── weblogic/
│   │   ├── weblogic.pkr.hcl
│   │   ├── weblogic-14.pkrvars.hcl # WebLogic 14.1.1 — latest
│   │   └── weblogic-12.pkrvars.hcl # WebLogic 12.2.1 — previous
│   ├── websphere/
│   │   ├── websphere.pkr.hcl
│   │   ├── websphere-9.pkrvars.hcl # WebSphere 9.0 — latest
│   │   └── websphere-8.pkrvars.hcl # WebSphere 8.5 — previous
│   ├── jboss/
│   │   ├── jboss.pkr.hcl
│   │   ├── jboss-8.pkrvars.hcl     # JBoss EAP 8.0 — latest
│   │   └── jboss-7.pkrvars.hcl     # JBoss EAP 7.4 — previous
│   ├── nginx/
│   │   ├── nginx.pkr.hcl
│   │   ├── nginx-1_27.pkrvars.hcl  # Nginx 1.27 — latest
│   │   └── nginx-1_26.pkrvars.hcl  # Nginx 1.26 — previous
│   ├── apache-httpd/
│   │   ├── apache-httpd.pkr.hcl
│   │   ├── apache-httpd-2_4.pkrvars.hcl # Apache HTTPD 2.4 — latest
│   │   └── apache-httpd-2_2.pkrvars.hcl # Apache HTTPD 2.2 — previous
│   └── tomcat/
│       ├── tomcat.pkr.hcl
│       ├── tomcat-11.pkrvars.hcl   # Tomcat 11.0 — latest
│       └── tomcat-10.pkrvars.hcl   # Tomcat 10.1 — previous
│
└── app/
    ├── frontend/
    │   ├── frontend.pkr.hcl
    │   ├── frontend-v2.pkrvars.hcl # v2.0.0 — current
    │   └── frontend-v1.pkrvars.hcl # v1.0.0 — previous
    ├── backend/
    │   ├── backend.pkr.hcl
    │   ├── backend-v2.pkrvars.hcl  # v2.0.0 — current
    │   └── backend-v1.pkrvars.hcl  # v1.0.0 — previous
    └── worker/
        ├── worker.pkr.hcl
        ├── worker-v2.pkrvars.hcl   # v2.0.0 — current
        └── worker-v1.pkrvars.hcl   # v1.0.0 — previous
```

---

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.9
- AWS credentials configured (`aws configure` or environment variables)
- A VPC and subnet in your target region with internet access for downloading packages

---

## Setup

### 1. Edit common variables

Open `common.pkrvars.hcl` and replace the placeholder values with your real AWS environment:

```hcl
aws_region    = "us-east-1"
vpc_id        = "vpc-xxxxxxxxxxxxxxxxx"
subnet_id     = "subnet-xxxxxxxxxxxxxxxxx"
instance_type = "t3.micro"
```

### 2. Initialize the Packer plugin

Run this once from any template directory (or from the workspace root):

```bash
packer init <template>.pkr.hcl
```

---

## How to Build

All builds follow the same two-file pattern:

```
packer build \
  -var-file=../../common.pkrvars.hcl \
  -var-file=<version>.pkrvars.hcl \
  <template>.pkr.hcl
```

The relative path `../../common.pkrvars.hcl` assumes you run the command **from inside the image directory**.

### Base Images

```bash
# Ubuntu 24.04
cd base/ubuntu
packer build -var-file=../../common.pkrvars.hcl -var-file=ubuntu-24.pkrvars.hcl ubuntu.pkr.hcl

# Ubuntu 22.04
packer build -var-file=../../common.pkrvars.hcl -var-file=ubuntu-22.pkrvars.hcl ubuntu.pkr.hcl

# RHEL 9
cd base/rhel
packer build -var-file=../../common.pkrvars.hcl -var-file=rhel-9.pkrvars.hcl rhel.pkr.hcl

# RHEL 8
packer build -var-file=../../common.pkrvars.hcl -var-file=rhel-8.pkrvars.hcl rhel.pkr.hcl

# Debian 12
cd base/debian
packer build -var-file=../../common.pkrvars.hcl -var-file=debian-12.pkrvars.hcl debian.pkr.hcl

# Rocky Linux 9
cd base/rocky
packer build -var-file=../../common.pkrvars.hcl -var-file=rocky-9.pkrvars.hcl rocky.pkr.hcl
```

### Middleware Images

> Before building a middleware image, set `source_ami` in the `.pkrvars.hcl` file to the AMI ID
> output by your base layer build.

```bash
# WebLogic 14.1.1
cd middleware/weblogic
packer build -var-file=../../common.pkrvars.hcl -var-file=weblogic-14.pkrvars.hcl weblogic.pkr.hcl

# JBoss EAP 8.0
cd middleware/jboss
packer build -var-file=../../common.pkrvars.hcl -var-file=jboss-8.pkrvars.hcl jboss.pkr.hcl

# Nginx 1.27
cd middleware/nginx
packer build -var-file=../../common.pkrvars.hcl -var-file=nginx-1_27.pkrvars.hcl nginx.pkr.hcl

# Tomcat 11.0
cd middleware/tomcat
packer build -var-file=../../common.pkrvars.hcl -var-file=tomcat-11.pkrvars.hcl tomcat.pkr.hcl
```

### Application Images

> Before building an app image, set `source_ami` in the `.pkrvars.hcl` file to the AMI ID
> output by your middleware or base layer build.

```bash
# Frontend v2
cd app/frontend
packer build -var-file=../../common.pkrvars.hcl -var-file=frontend-v2.pkrvars.hcl frontend.pkr.hcl

# Backend v2
cd app/backend
packer build -var-file=../../common.pkrvars.hcl -var-file=backend-v2.pkrvars.hcl backend.pkr.hcl

# Worker v1
cd app/worker
packer build -var-file=../../common.pkrvars.hcl -var-file=worker-v1.pkrvars.hcl worker.pkr.hcl
```

---

## Variable File Convention

| File | Purpose |
|------|---------|
| `common.pkrvars.hcl` | Shared AWS infrastructure variables — region, VPC, subnet, instance type |
| `<name>-<version>.pkrvars.hcl` | Version-specific variables — AMI filter or version label, source AMI, output AMI name |

Each template defines `variable` blocks for everything it needs. You always pass **two** `-var-file` flags:
1. `../../common.pkrvars.hcl` — infrastructure
2. `<version>.pkrvars.hcl` — image-specific values

---

## Build Order

When building a full stack, respect the dependency chain:

```
base  →  middleware  →  app
```

The `source_ami` variable in middleware and app `pkrvars` files must be set to the AMI ID
produced by the previous layer's build.

---

## AMI Owners Reference

| Distro | AWS Account ID |
|--------|---------------|
| Ubuntu (Canonical) | `099720109477` |
| RHEL (Red Hat) | `309956199498` |
| Debian | `136693071363` |
| Rocky Linux | `792107900819` |

---

## Validate Without Building

Use `packer validate` to syntax-check any template without launching an AWS instance:

```bash
cd base/ubuntu
packer validate -var-file=../../common.pkrvars.hcl -var-file=ubuntu-24.pkrvars.hcl ubuntu.pkr.hcl
```
