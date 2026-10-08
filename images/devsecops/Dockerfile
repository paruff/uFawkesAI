# syntax=docker/dockerfile:1
# uFawkes DevSecOps toolchain image — see docs/ai-sdlc/devsecops-image/spec.md.
#
#   docker buildx build --target core -t fawkes-core images/devsecops
#
# Determinism: base pinned by digest, apt pinned to a dated snapshot, every
# downloaded tool pinned by SHA-256 in tools.lock.json, Python deps
# hash-locked, Node deps from package-lock.json.

ARG APT_SNAPSHOT=20261004T000000Z

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
FROM fetch AS fetch-ai
RUN mkdir -p /out/ai/etc \
 && cp -a /out/core/etc/ufawkes /out/ai/etc/ \
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
      bash ca-certificates curl git make openssh-client python3 xz-utils \
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

# Hook environments are not pre-baked (AC-AI-09, owner decision 2026-10-03):
# a repo's remote-rev hooks download once into the user's ~/.cache/pre-commit
# on first run. The baseline's hooks are language: system and need none.

LABEL org.opencontainers.image.source="https://github.com/paruff/uFawkesAI" \
      org.opencontainers.image.description="uFawkes DevSecOps toolchain (core): pre-commit, linters, secret/vuln/SAST scanners" \
      org.opencontainers.image.licenses="MIT"
CMD ["bash"]

# ── ai: + agent harness, non-root devcontainer user ───────────────────────
# Claude Code is not baked in: its licence reserves all rights, so the
# devcontainer installs the pinned version from npm at create time (spec R2
# fallback). NPM_CONFIG_PREFIX lets `dev` do that without sudo.
FROM core AS ai
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
# From one hash-locked package-lock.json: Codex and Gemini CLI (so all four
# harnesses the smoke test checks ship), qmd (local markdown search + MCP
# server), and the TypeScript/JavaScript, Python, Bash and YAML language
# servers. qmd's better-sqlite3 is the one package whose install script must
# run (it fetches its native binding); node-llama-cpp's GPU builds are pruned
# (CPU only in a devcontainer; builds for other platforms are dropped too), and
# so is Codex's voice-mode host (62 MB; a container has no microphone).
COPY node-ai/package.json node-ai/package-lock.json /opt/ufawkes/node-ai/
RUN npm ci --prefix /opt/ufawkes/node-ai --omit=dev --ignore-scripts --no-audit --no-fund \
 && npm rebuild --prefix /opt/ufawkes/node-ai better-sqlite3 \
 && keep="linux-$(case "$(dpkg --print-architecture)" in amd64) echo x64 ;; *) echo arm64 ;; esac)" \
 && find /opt/ufawkes/node-ai/node_modules/@node-llama-cpp -mindepth 1 -maxdepth 1 ! -name "$keep" -exec rm -rf {} + \
 && find /opt/ufawkes/node-ai/node_modules/@openai -type d -path '*/codex-resources/voice' -prune -exec rm -rf {} + \
 && for b in codex gemini qmd typescript-language-server tsserver pyright pyright-langserver \
             bash-language-server yaml-language-server; do \
      ln -s "/opt/ufawkes/node-ai/node_modules/.bin/${b}" "/usr/local/bin/${b}"; \
    done \
 && npm cache clean --force
# OpenCode would otherwise download missing language servers at runtime; every
# server it needs is baked in above, so a download is never the answer.
ENV NPM_CONFIG_PREFIX=/home/${DEV_USER}/.npm-global \
    PATH=/home/${DEV_USER}/.npm-global/bin:$PATH \
    OPENCODE_DISABLE_LSP_DOWNLOAD=true
LABEL org.opencontainers.image.description="uFawkes DevSecOps toolchain (ai): core + OpenCode, Codex, Gemini CLI, Superpowers agent skills, devcontainer user"
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}
# The versioned OpenCode config (opencode/: fixed model per agent, no model
# router, fallback off, pinned plugins from package-lock.json) and the four
# uFawkesAI agents are baked in, so no container ever runs sync.sh by hand.
# Claude Code gets the same four agents in ~/.claude/agents.
COPY --from=opencode-src --chown=${DEV_USER}:${DEV_USER} . /tmp/oc/opencode/
COPY --from=agents-src --chown=${DEV_USER}:${DEV_USER} . /tmp/oc/.agents/agents/
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" \
 && bash /tmp/oc/opencode/sync.sh --apply \
 && mkdir -p .claude/agents && cp .config/opencode/agents/*.md .claude/agents/ \
 && rm -rf /tmp/oc .npm/_cacache
# Locked agent skills (/opt/agent-skills, from tools.lock.json), so every repo
# on this image — the uFawkes suite and fawkes — gets them without setup.
# Claude Code: all of them. OpenCode already registers Superpowers through the
# config's skills.paths (same pinned version), so it links only the others:
# a second registration triggers "duplicate skill name" warnings.
# qmd ships its own skill, pinned with the qmd package: installed to
# ~/.agents/skills/qmd and linked into both harnesses.
RUN qmd skill install --global --force \
 && mkdir -p .claude/skills .config/opencode/skills \
 && ln -sfn "$HOME/.agents/skills/qmd" .claude/skills/qmd \
 && ln -sfn "$HOME/.agents/skills/qmd" .config/opencode/skills/qmd \
 && for s in /opt/agent-skills/*/*/; do ln -sfn "${s%/}" ".claude/skills/$(basename "${s}")"; done \
 && for s in /opt/agent-skills/*/*/; do \
      case "$s" in /opt/agent-skills/superpowers/*) continue ;; esac; \
      ln -sfn "${s%/}" ".config/opencode/skills/$(basename "${s}")"; \
    done
CMD ["zsh"]
