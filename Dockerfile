# syntax=docker/dockerfile:1

FROM node:22.1.0-alpine AS builder

WORKDIR /app

# Copy manifests first to cache the npm ci layer across source-only changes.
COPY package.json package-lock.json ./

# --omit=dev: no devDependencies in the image.
# --ignore-scripts: blocks dependency install-time scripts (supply-chain hardening).
RUN npm ci --omit=dev --ignore-scripts

COPY app.js ./

# Distroless: no shell, no package manager, nothing for a compromised
# process to pivot with. Pinned by digest (nonroot variant, uid 65532).
FROM gcr.io/distroless/nodejs22-debian13:nonroot@sha256:10747a1323be68f206aed893599d43e6697ad67257e7c42703553f99fbce3d33

ENV NODE_ENV=production

WORKDIR /app

COPY --from=builder --chown=65532:65532 /app ./

EXPOSE 8080

# Base image's ENTRYPOINT is already ["/nodejs/bin/node"]; CMD supplies the
# script argument. Already runs as uid 65532 (nonroot) by default.
CMD ["app.js"]

# No HEALTHCHECK: Kubernetes liveness/readiness probes own health checking.
