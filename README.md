# sample-nodejs

A lightweight Node.js/Express app, deployed to AWS EKS via a GitOps pipeline:
GitHub Actions (SAST + image scan) → ECR → ArgoCD → Kubernetes, with Terraform-managed infrastructure for the AWS side.

**Live:** https://sample-nodejs.catsweather.online/my-app

## Overview

Express app, demonstrating a defensible DevSecOps pipeline end to end.

| Endpoint | Purpose |
|---|---|
| `/my-app` | Main route |
| `/about` | App info |
| `/ready`, `/live` | K8s probes (kubelet only) |

## Architecture

```
Developer → GitHub Actions (SAST, Trivy) → ECR → sample-nodejs-gitops (image tag) → ArgoCD → EKS
```

This repo: app source, CI, AWS infra (Terraform). K8s/ArgoCD config lives in
[sample-nodejs-gitops](https://github.com/harel2320-dev/sample-nodejs-gitops)
(`platform/` = cluster-wide tooling, `apps/sample-nodejs/` = this app's Helm
chart + Application CR — CI only touches its `values.yaml` image tag, via a
short-lived GitHub App token).

## Tech stack

Node.js 22.1.0 / Express · multi-stage distroless container, non-root,
read-only rootfs · AWS EKS (tainted platform node group isolates
ArgoCD/ALB-controller) · Helm + ArgoCD (GitOps) · Terraform (VPC, EKS, ECR,
Route53, ACM, IAM) · GitHub Actions with OIDC to AWS (no static credentials)

## Security

- **SAST:** Semgrep, blocks PR on findings.
- **Image scan:** Trivy, blocks on HIGH/CRITICAL before push.
- **DAST:** OWASP ZAP baseline scan (scheduled + on-demand).
- **Dependencies:** Dependabot alerts + updates.
- **Secrets:** GitHub push protection; no static cloud creds — OIDC to AWS, short-lived GitHub App token to the GitOps repo.
- **Runtime:** non-root, read-only rootfs, dedicated namespace, least-privilege IAM (Pod Identity), TLS at the edge (ACM + ALB).

## Repository layout

```
app.js, package.json       app source
Dockerfile                 multi-stage, distroless
terraform/                 AWS infrastructure (bootstrap + main)
.github/workflows/         CI (ci.yml) and DAST (dast.yml)
```

K8s/ArgoCD config: [sample-nodejs-gitops](https://github.com/harel2320-dev/sample-nodejs-gitops).
