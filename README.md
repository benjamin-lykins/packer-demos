# Packer Build Pipeline

A structured Packer image pipeline for AWS (`amazon-ebs`) with three layers:

| Layer | Purpose |
|-------|---------|
| **base** | Hardened OS images — Ubuntu, RHEL, Debian, Rocky Linux |
| **middleware** | Runtime platform images built on top of a base AMI — WebLogic, WebSphere, JBoss, Nginx, Apache HTTPD, Tomcat |
| **app** | Application images built on top of a middleware or base AMI — frontend, backend, worker |

Each layer has one shared Packer template; version-specific `.pkrvars.hcl` files under product subdirectories drive differentiation.

---

## Directory Structure

```
packer-demos/
├── common.pkrvars.hcl              # Shared AWS variables (region, VPC, subnet, instance type)
│
├── base/
│   ├── base.pkr.hcl                # Shared base template
│   ├── ubuntu/
│   │   ├── ubuntu-24.pkrvars.hcl   # Ubuntu 24.04 LTS — latest
│   │   └── ubuntu-22.pkrvars.hcl   # Ubuntu 22.04 LTS — previous
│   ├── rhel/
│   │   ├── rhel-9.pkrvars.hcl      # RHEL 9 — latest
│   │   └── rhel-8.pkrvars.hcl      # RHEL 8 — previous
│   ├── debian/
│   │   ├── debian-12.pkrvars.hcl   # Debian 12 Bookworm — latest
│   │   └── debian-11.pkrvars.hcl   # Debian 11 Bullseye — previous
│   └── rocky/
│       ├── rocky-9.pkrvars.hcl     # Rocky Linux 9 — latest
│       └── rocky-8.pkrvars.hcl     # Rocky Linux 8 — previous
│
├── middleware/
│   ├── middleware.pkr.hcl          # Shared middleware template
│   ├── weblogic/
│   │   ├── weblogic-14.pkrvars.hcl # WebLogic 14.1.1 — latest
│   │   └── weblogic-12.pkrvars.hcl # WebLogic 12.2.1 — previous
│   ├── websphere/
│   │   ├── websphere-9.pkrvars.hcl # WebSphere 9.0 — latest
│   │   └── websphere-8.pkrvars.hcl # WebSphere 8.5 — previous
│   ├── jboss/
│   │   ├── jboss-8.pkrvars.hcl     # JBoss EAP 8.0 — latest
│   │   └── jboss-7.pkrvars.hcl     # JBoss EAP 7.4 — previous
│   ├── nginx/
│   │   ├── nginx-1_27.pkrvars.hcl  # Nginx 1.27 — latest
│   │   └── nginx-1_26.pkrvars.hcl  # Nginx 1.26 — previous
│   ├── apache-httpd/
│   │   ├── apache-httpd-2_4.pkrvars.hcl # Apache HTTPD 2.4 — latest
│   │   └── apache-httpd-2_2.pkrvars.hcl # Apache HTTPD 2.2 — previous
│   └── tomcat/
│       ├── tomcat-11.pkrvars.hcl   # Tomcat 11.0 — latest
│       └── tomcat-10.pkrvars.hcl   # Tomcat 10.1 — previous
│
└── app/
    ├── app.pkr.hcl                 # Shared app template
    ├── frontend/
    │   ├── frontend-v2.pkrvars.hcl # v2.0.0 — current
    │   └── frontend-v1.pkrvars.hcl # v1.0.0 — previous
    ├── backend/
    │   ├── backend-v2.pkrvars.hcl  # v2.0.0 — current
    │   └── backend-v1.pkrvars.hcl  # v1.0.0 — previous
    └── worker/
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

Run this once from the layer root:

```bash
cd base && packer init base.pkr.hcl
cd ../middleware && packer init middleware.pkr.hcl
cd ../app && packer init app.pkr.hcl
```

---

## How to Build

All builds follow the same two-file pattern, run from the layer root (`base/`, `middleware/`, or `app/`):

```
packer build \
  -var-file=../common.pkrvars.hcl \
  -var-file=<product>/<version>.pkrvars.hcl \
  <layer>.pkr.hcl
```

### Base Images

```bash
cd base

# Ubuntu 24.04
packer build -var-file=../common.pkrvars.hcl -var-file=ubuntu/ubuntu-24.pkrvars.hcl base.pkr.hcl

# Ubuntu 22.04
packer build -var-file=../common.pkrvars.hcl -var-file=ubuntu/ubuntu-22.pkrvars.hcl base.pkr.hcl

# RHEL 9
packer build -var-file=../common.pkrvars.hcl -var-file=rhel/rhel-9.pkrvars.hcl base.pkr.hcl

# RHEL 8
packer build -var-file=../common.pkrvars.hcl -var-file=rhel/rhel-8.pkrvars.hcl base.pkr.hcl

# Debian 12
packer build -var-file=../common.pkrvars.hcl -var-file=debian/debian-12.pkrvars.hcl base.pkr.hcl

# Rocky Linux 9
packer build -var-file=../common.pkrvars.hcl -var-file=rocky/rocky-9.pkrvars.hcl base.pkr.hcl
```

### Middleware Images

> Before building a middleware image, set `source_ami` in the `.pkrvars.hcl` file to the AMI ID
> output by your base layer build (or rely on HCP Packer channel lookup).

```bash
cd middleware

# WebLogic 14.1.1
packer build -var-file=../common.pkrvars.hcl -var-file=weblogic/weblogic-14.pkrvars.hcl middleware.pkr.hcl

# JBoss EAP 8.0
packer build -var-file=../common.pkrvars.hcl -var-file=jboss/jboss-8.pkrvars.hcl middleware.pkr.hcl

# Nginx 1.27
packer build -var-file=../common.pkrvars.hcl -var-file=nginx/nginx-1_27.pkrvars.hcl middleware.pkr.hcl

# Tomcat 11.0
packer build -var-file=../common.pkrvars.hcl -var-file=tomcat/tomcat-11.pkrvars.hcl middleware.pkr.hcl
```

### Application Images

> Before building an app image, set `source_ami` in the `.pkrvars.hcl` file to the AMI ID
> output by your middleware or base layer build (or rely on HCP Packer channel lookup).

```bash
cd app

# Frontend v2
packer build -var-file=../common.pkrvars.hcl -var-file=frontend/frontend-v2.pkrvars.hcl app.pkr.hcl

# Backend v2
packer build -var-file=../common.pkrvars.hcl -var-file=backend/backend-v2.pkrvars.hcl app.pkr.hcl

# Worker v1
packer build -var-file=../common.pkrvars.hcl -var-file=worker/worker-v1.pkrvars.hcl app.pkr.hcl
```

---

## Variable File Convention

| File | Purpose |
|------|---------|
| `common.pkrvars.hcl` | Shared AWS infrastructure variables — region, VPC, subnet, instance type |
| `<product>/<name>-<version>.pkrvars.hcl` | Version-specific variables — AMI filter or version label, source AMI, output AMI name |

Each shared template defines `variable` blocks for everything it needs. You always pass **two** `-var-file` flags from the layer root:
1. `../common.pkrvars.hcl` — infrastructure
2. `<product>/<version>.pkrvars.hcl` — image-specific values

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
cd base
packer validate -var-file=../common.pkrvars.hcl -var-file=ubuntu/ubuntu-24.pkrvars.hcl base.pkr.hcl
```
