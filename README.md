# sample-nodejs

A lightweight Node.js/Express app, deployed to AWS EKS via a GitOps pipeline:
GitHub Actions (SAST + image scan) → ECR → ArgoCD → Kubernetes, with Terraform-managed infrastructure for the AWS side.

**Live:** https://sample-nodejs.catsweather.online/my-app

## Overview

Express web server with Prometheus metrics, readiness/liveness probes, and
security response headers (`helmet`). Built to demonstrate a complete,
defensible DevSecOps pipeline — every tool and configuration choice here was
made deliberately, not defaulted to.

| Endpoint | Purpose | Public |
|---|---|---|
| `/my-app` | Main route | Yes |
| `/about` | App info | Yes |
| `/ready`, `/live` | K8s probes | No (kubelet only) |
| `/metrics` | Prometheus | No |
| `/classified` | Demo route | No |

## Architecture

```
Developer → GitHub Actions (SAST, Trivy) → ECR
                                          ↓
                          sample-nodejs-gitops repo (image tag)
                                          ↓
                                       ArgoCD → EKS
```

This repo holds app source, CI pipeline, and AWS infrastructure (Terraform)
only — nothing Kubernetes-side. All deployment config lives in
[sample-nodejs-gitops](https://github.com/harel2320-dev/sample-nodejs-gitops):

- `platform/` — cluster-wide tooling (ArgoCD, ALB controller), installed once, not tied to any single app.
- `apps/sample-nodejs/` — this app's full Helm chart plus its ArgoCD `Application` CR. CI only ever touches `apps/sample-nodejs/values.yaml` (the image tag), via a short-lived, repo-scoped GitHub App token.

Structured to scale to a second app later (`apps/<name>/`, sharing the same `platform/`) without reshaping anything.

## Tech stack

- **App:** Node.js 22.1.0, Express, prom-client, helmet
- **Container:** multi-stage build → distroless, non-root, read-only root filesystem
- **Orchestration:** AWS EKS (two node groups — app workload, and a tainted platform group isolating ArgoCD/ALB-controller from it)
- **Deployment:** Helm + ArgoCD (GitOps), config in a separate repo
- **Infrastructure:** Terraform (VPC, EKS, ECR, Route53, ACM, IAM)
- **CI/CD:** GitHub Actions, OIDC to AWS (no static credentials)

## Security

- **SAST:** Semgrep, blocks the PR on findings.
- **Image scanning:** Trivy, blocks on HIGH/CRITICAL before push.
- **DAST:** OWASP ZAP baseline scan against the live app (scheduled + on-demand).
- **Dependencies:** Dependabot alerts + security updates.
- **Secrets:** GitHub push protection enabled; no static cloud credentials anywhere in the pipeline — GitHub Actions authenticates to AWS via OIDC, and to the GitOps repo via a short-lived, repo-scoped GitHub App token.
- **Runtime:** non-root, read-only root filesystem, dedicated namespace, least-privilege IAM (EKS Pod Identity), TLS at the edge (ACM + ALB).

## Local development

```bash
npm ci
npm start   # http://localhost:8080
```

## Repository layout

```
app.js, package.json       app source
Dockerfile                 multi-stage, distroless
terraform/                 AWS infrastructure (bootstrap + main)
.github/workflows/         CI (ci.yml) and DAST (dast.yml)
```

Kubernetes/ArgoCD config lives entirely in
[sample-nodejs-gitops](https://github.com/harel2320-dev/sample-nodejs-gitops).
