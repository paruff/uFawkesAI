# syntax=docker/dockerfile:1
# uFawkes DevSecOps toolchain image — see docs/ai-sdlc/devsecops-image/spec.md.
#
#   docker buildx build --target core -t ufawkes-devsecops-core images/devsecops
#
# Determinism: base pinned by digest, apt pinned to a dated snapshot, every
# downloaded tool pinned by SHA-256 in tools.lock.json, Python deps
# hash-locked, Node deps from package-lock.json.

ARG BASE_IMAGE=docker.io/library/debian:trixie-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a
ARG APT_SNAPSHOT=20260926T000000Z

# ── base: Debian pinned to an apt snapshot ─────────────────────────────────
FROM ${BASE_IMAGE} AS base
ARG APT_SNAPSHOT
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# The snapshot date fixes every apt package version, so per-package pins
# (hadolint DL3008) would be redundant.
RUN sed -i \
      -e "s|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/${APT_SNAPSHOT}|" \
      -e "s|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/${APT_SNAPSHOT}|" \
      /etc/apt/sources.list.d/debian.sources \
 && echo 'Acquire::Check-Valid-Until "false";' >/etc/apt/apt.conf.d/99snapshot \
 && echo 'Acquire::Retries "5";' >>/etc/apt/apt.conf.d/99snapshot

# ── fetch: download + checksum-verify locked tools ─────────────────────────
FROM base AS fetch
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl jq xz-utils \
 && rm -rf /var/lib/apt/lists/*
COPY tools.lock.json install-tools.sh /build/
RUN /build/install-tools.sh /build/tools.lock.json core /out

# ── core: pre-commit, linters, secret/vuln/SAST scanners ───────────────────
FROM base AS core
ENV LANG=C.UTF-8 \
    PATH=/opt/ufawkes/venv/bin:$PATH \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS=never
# safe.directory: CI checkouts are owned by a different UID than the container user.
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash ca-certificates git make openssh-client python3 xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && git config --system --add safe.directory '*'

COPY --from=fetch /out/ /

COPY python/requirements.lock /opt/ufawkes/python/requirements.lock
RUN uv venv --python /usr/bin/python3 /opt/ufawkes/venv \
 && uv pip install --python /opt/ufawkes/venv --require-hashes \
      -r /opt/ufawkes/python/requirements.lock

COPY node/package.json node/package-lock.json /opt/ufawkes/node/
RUN npm ci --prefix /opt/ufawkes/node --omit=dev --ignore-scripts --no-audit --no-fund \
 && ln -s /opt/ufawkes/node/node_modules/.bin/markdownlint-cli2 /usr/local/bin/markdownlint-cli2 \
 && npm cache clean --force

COPY tools.lock.json /etc/ufawkes/tools.lock.json
COPY python/requirements.in /etc/ufawkes/requirements.in
COPY pre-commit/baseline.yaml /opt/ufawkes/pre-commit/baseline.yaml

LABEL org.opencontainers.image.source="https://github.com/paruff/uFawkesAI" \
      org.opencontainers.image.description="uFawkes DevSecOps toolchain (core): pre-commit, linters, secret/vuln/SAST scanners" \
      org.opencontainers.image.licenses="MIT"
CMD ["bash"]
