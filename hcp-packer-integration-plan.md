# HCP Packer Registry Integration Plan

## Overview

Integrate HCP Packer registry into the existing three-tier AMI build pipeline.
Every Packer build will push its artifact metadata to the HCP Packer registry
under the configured project. The HCP service principal credentials and project
ID will be stored exclusively as GitHub repository secrets. A dynamic build
fingerprint will be generated per-job at runtime (derived from the GitHub run
ID and matrix values) so that every matrix build has a unique, traceable
fingerprint.

**Scope:** 13 Packer templates (4 base, 3 app, 6 middleware) + 3 GitHub workflow
files (packer-base.yml, packer-middleware.yml, packer-app.yml).

**Out of scope:** packer-full-pipeline.yml (orchestrator only — no build steps),
matrix-output.yml (no build steps).

---

## Sub-Tasks

---

### Sub-Task 1 — Add GitHub Secrets

**Intent**
Store the three HCP credentials as GitHub repository secrets so they are
available to workflows without ever appearing in source code.

**Expected Outcomes**
- `HCP_CLIENT_ID` secret exists in the repository
- `HCP_CLIENT_SECRET` secret exists in the repository
- `HCP_PROJECT_ID` secret exists in the repository
- None of these values appear anywhere in committed files

**Todo List**
1. In the GitHub repository → Settings → Secrets and variables → Actions →
   Repository secrets, create:
   - `HCP_CLIENT_ID` = `8a15620476c591a7ef5340f09950a4e6`
   - `HCP_CLIENT_SECRET` = `a3d51505b2a189aa960aa980dc8cf9696d92e5a41f683c146e292492c00b1df1`
   - `HCP_PROJECT_ID` = `93a10de7-447a-4c22-9747-1460824bda5a`

**Relevant Context**
- All three workflow build jobs reference the `aws-packer` environment; secrets
  may also be stored at environment scope if desired. Repository-level secrets
  are sufficient for this integration.

**Status** — `[ ] pending` *(manual step — cannot be automated)*

---

### Sub-Task 2 — Add `hcp_packer_registry` block to all 13 Packer templates

**Intent**
Each `.pkr.hcl` template needs an `hcp_packer_registry` block inside its
`build {}` block so Packer knows which HCP bucket to publish artifact metadata
to. The bucket name is derived from the build's existing `name` attribute
(e.g. `base-ubuntu-24.04` becomes the HCP bucket slug). The channel will be
left at the HCP default (no explicit channel stanza needed for basic registry
publishing).

**Expected Outcomes**
- All 13 templates contain an `hcp_packer_registry` block inside `build {}`
- The `bucket_name` in each block matches the template's existing `build name`
  value so naming is consistent
- No new variables are introduced in the templates (project ID is supplied
  via `HCP_PACKER_BUCKET_NAME` / env-var-less approach; credentials are
  supplied via env vars `HCP_CLIENT_ID`, `HCP_CLIENT_SECRET`,
  `HCP_PROJECT_ID` at runtime — the block only needs `bucket_name`)

**Todo List**

For each of the 13 files below, add an `hcp_packer_registry` block inside the
`build {}` block, immediately after the opening `build {` line and before
`sources = [...]`:

| File | bucket_name value |
|------|-------------------|
| `base/ubuntu/ubuntu.pkr.hcl` | `"base-ubuntu-${var.os_version}"` |
| `base/debian/debian.pkr.hcl` | `"base-debian-${var.os_version}"` |
| `base/rhel/rhel.pkr.hcl` | `"base-rhel-${var.os_version}"` |
| `base/rocky/rocky.pkr.hcl` | `"base-rocky-${var.os_version}"` |
| `middleware/nginx/nginx.pkr.hcl` | `"middleware-nginx-${var.middleware_version}"` |
| `middleware/apache-httpd/apache-httpd.pkr.hcl` | `"middleware-apache-httpd-${var.middleware_version}"` |
| `middleware/tomcat/tomcat.pkr.hcl` | `"middleware-tomcat-${var.middleware_version}"` |
| `middleware/jboss/jboss.pkr.hcl` | `"middleware-jboss-${var.middleware_version}"` |
| `middleware/websphere/websphere.pkr.hcl` | `"middleware-websphere-${var.middleware_version}"` |
| `middleware/weblogic/weblogic.pkr.hcl` | `"middleware-weblogic-${var.middleware_version}"` |
| `app/frontend/frontend.pkr.hcl` | `"app-frontend-${var.app_version}"` |
| `app/backend/backend.pkr.hcl` | `"app-backend-${var.app_version}"` |
| `app/worker/worker.pkr.hcl` | `"app-worker-${var.app_version}"` |

Block shape to insert (example for ubuntu):
```hcl
  hcp_packer_registry {
    bucket_name = "base-ubuntu-${var.os_version}"
    description = "Base Ubuntu ${var.os_version} image"
    bucket_labels = {
      "layer" = "base"
      "os"    = "ubuntu"
    }
  }
```
Adjust `description` and `bucket_labels` to match each template's tier and
component.

**Relevant Context**
- All templates currently have no `hcp_packer_registry` block
- Build names are the natural bucket name candidates (confirmed by sub-agent
  exploration)
- Credential env vars (`HCP_CLIENT_ID`, `HCP_CLIENT_SECRET`, `HCP_PROJECT_ID`)
  are injected by the workflow — the template block itself does not reference
  them directly

**Status** — `[x] done`

---

### Sub-Task 3 — Update the three build workflow files

**Intent**
Each build job in `packer-base.yml`, `packer-middleware.yml`, and
`packer-app.yml` must:
1. Export `HCP_CLIENT_ID`, `HCP_CLIENT_SECRET`, and `HCP_PROJECT_ID` as env
   vars (from secrets) so Packer can authenticate to HCP.
2. Generate a **dynamic** `HCP_PACKER_BUILD_FINGERPRINT` per matrix job
   (unique per run + matrix element) so parallel matrix builds don't collide.
3. Update the header comment block to document the new required secrets.

The `validate` jobs do **not** need HCP credentials — validation does not push
to HCP.

**Expected Outcomes**
- Each build job step that runs `packer build` has the four HCP env vars set
- `HCP_PACKER_BUILD_FINGERPRINT` is unique per job: recommended value is
  `${{ github.run_id }}-${{ matrix.<key> }}-${{ matrix.version }}`
- Header comments in all three workflow files list the new secrets
- The validate jobs are unchanged (no HCP vars injected)

**Todo List**

**packer-base.yml**
1. Add to the header comment's "Required repository secrets" list:
   `HCP_CLIENT_ID`, `HCP_CLIENT_SECRET`, `HCP_PROJECT_ID`
2. In the `build` job, add an `env:` block at the job level (or on the
   `Packer build` step) with:
   ```yaml
   HCP_CLIENT_ID:     ${{ secrets.HCP_CLIENT_ID }}
   HCP_CLIENT_SECRET: ${{ secrets.HCP_CLIENT_SECRET }}
   HCP_PROJECT_ID:    ${{ secrets.HCP_PROJECT_ID }}
   HCP_PACKER_BUILD_FINGERPRINT: "${{ github.run_id }}-${{ matrix.distro }}-${{ matrix.version }}"
   ```

**packer-middleware.yml**
1. Same header comment update
2. Same `env:` additions, fingerprint key:
   `"${{ github.run_id }}-${{ matrix.middleware }}-${{ matrix.version }}"`

**packer-app.yml**
1. Same header comment update
2. Same `env:` additions, fingerprint key:
   `"${{ github.run_id }}-${{ matrix.app }}-${{ matrix.version }}"`

**Relevant Context**
- Env vars are placed at the **job level** `env:` so all steps in the build
  job inherit them (avoids duplication across init / validate / build steps)
- HCP Packer reads `HCP_CLIENT_ID`, `HCP_CLIENT_SECRET`, `HCP_PROJECT_ID`,
  and `HCP_PACKER_BUILD_FINGERPRINT` automatically from the environment — no
  CLI flags needed
- Fingerprint collision would cause a build failure in HCP if two matrix jobs
  share the same value; using `run_id + matrix key + version` guarantees
  uniqueness within and across runs

**Status** — `[x] done`

---

## Implementation Notes

- Sub-Task 1 is a manual GitHub UI step — it cannot be automated via code
  changes. It must be done before any workflow run that pushes to HCP.
- Sub-Tasks 2 and 3 are purely code changes and can be done in either order,
  but both must land before the next build run.
- The `packer-full-pipeline.yml` file uses `secrets: inherit` on all three
  tier calls, so the new secrets will automatically be forwarded — no changes
  needed there.
