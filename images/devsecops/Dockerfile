# syntax=docker/dockerfile:1
# uFawkes DevSecOps toolchain image — see docs/ai-sdlc/devsecops-image/spec.md.
#
#   docker buildx build --target core -t ufawkes-devsecops-core images/devsecops
#
# Determinism: base pinned by digest, apt pinned to a dated snapshot, every
# downloaded tool pinned by SHA-256 in tools.lock.json, Python deps
# hash-locked, Node deps from package-lock.json.

ARG APT_SNAPSHOT=20260926T000000Z

# ── base: Debian pinned to an apt snapshot ─────────────────────────────────
# Digest pinned in FROM itself so Dependabot's docker updater can bump it.
FROM docker.io/library/debian:trixie-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a AS base
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
 && apt-get install -y --no-install-recommends ca-certificates curl jq unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*
COPY tools.lock.json install-tools.sh /build/
RUN /build/install-tools.sh /build/tools.lock.json core /out/core

# Each later variant starts from the previous variant's manifest, so
# /etc/ufawkes/tools.json always lists every tool the image contains.
FROM fetch AS fetch-gitops
RUN mkdir -p /out/gitops/etc \
 && cp -a /out/core/etc/ufawkes /out/gitops/etc/ \
 && /build/install-tools.sh /build/tools.lock.json gitops /out/gitops

FROM fetch-gitops AS fetch-ai
RUN mkdir -p /out/ai/etc \
 && cp -a /out/gitops/etc/ufawkes /out/ai/etc/ \
 && /build/install-tools.sh /build/tools.lock.json ai /out/ai

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

COPY --from=fetch /out/core/ /

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

# ── gitops: + Kubernetes, GitOps, IaC, policy-as-code, secrets-in-Git ──────
FROM core AS gitops
COPY --from=fetch-gitops /out/gitops/ /
# checkov gets its own venv so its deps never conflict with semgrep's.
COPY python/requirements-gitops.lock /opt/ufawkes/python/requirements-gitops.lock
COPY python/requirements-gitops.in /etc/ufawkes/requirements-gitops.in
RUN uv venv --python /usr/bin/python3 /opt/ufawkes/venv-gitops \
 && uv pip install --python /opt/ufawkes/venv-gitops --require-hashes \
      -r /opt/ufawkes/python/requirements-gitops.lock \
 && ln -s /opt/ufawkes/venv-gitops/bin/checkov /usr/local/bin/checkov
LABEL org.opencontainers.image.description="uFawkes DevSecOps toolchain (gitops): core + Kubernetes, GitOps, IaC and policy-as-code tools"

# ── ai: + agent harness, non-root devcontainer user ───────────────────────
# Claude Code is not baked in: its licence reserves all rights, so the
# devcontainer installs the pinned version from npm at create time (spec R2
# fallback). NPM_CONFIG_PREFIX lets `dev` do that without sudo.
FROM gitops AS ai
ARG DEV_USER=dev
ARG USER_UID=1000
COPY --from=fetch-ai /out/ai/ /
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends less sudo vim-tiny zsh \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --gid "${USER_UID}" "${DEV_USER}" \
 && useradd --uid "${USER_UID}" --gid "${USER_UID}" --create-home --shell /usr/bin/zsh "${DEV_USER}" \
 && echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >"/etc/sudoers.d/${DEV_USER}" \
 && chmod 0440 "/etc/sudoers.d/${DEV_USER}"
ENV NPM_CONFIG_PREFIX=/home/${DEV_USER}/.npm-global \
    PATH=/home/${DEV_USER}/.npm-global/bin:$PATH
LABEL org.opencontainers.image.description="uFawkes DevSecOps toolchain (ai): gitops + OpenCode, devcontainer user"
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}
CMD ["zsh"]
