# syntax=docker/dockerfile:1

FROM node:22.1.0-alpine

LABEL org.opencontainers.image.title="sample-nodejs" \
      org.opencontainers.image.description="DevOps sample Express app" \
      org.opencontainers.image.source="https://github.com/harel2320-dev/sample-nodejs"

ENV NODE_ENV=production

WORKDIR /app

# Copy manifests first to cache the npm ci layer across source-only changes.
COPY --chown=node:node package.json package-lock.json ./

# --omit=dev: no devDependencies in the image.
# --ignore-scripts: blocks dependency install-time scripts (supply-chain hardening).
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

COPY --chown=node:node app.js ./

# Run as non-root.
USER node

EXPOSE 8080

# Exec form so Node runs as PID 1 and receives signals directly.
CMD ["node", "app.js"]

# No HEALTHCHECK: Kubernetes liveness/readiness probes own health checking.
