# syntax=docker/dockerfile:1
# uFawkesAI devcontainer image — the shared image for the uFawkes suite and fawkes.
# Published to ghcr.io/paruff/fawkes-space by build-devsecops-images.yml.
#
# The ai base already includes: OpenCode, qmd, the language servers (TS/JS,
# Python, Bash, YAML), Superpowers + qmd agent skills
# (linked into ~/.claude/skills and ~/.config/opencode/skills), pre-commit,
# gh, the core scanners, zsh, sudo, and the dev user.

ARG BASE_IMAGE=ghcr.io/paruff/fawkes-space-ai:latest
FROM ${BASE_IMAGE}

# Claude Code from npm (licence reserves all rights — not baked in the base image).
# The base sets NPM_CONFIG_PREFIX to a dev-owned dir, so no sudo is needed.
ARG CLAUDE_CODE_VERSION=2.1.293
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
  && npm cache clean --force

# Code intelligence + qmd for Claude Code. The language servers and qmd ship in
# the ai base; the local ufawkes-lsp plugin (.devcontainer/claude-plugins) tells
# Claude Code how to start them, and qmd is a user-scope MCP server so every
# repo opened in this container gets it.
# LSP_PLUGINS: the plugins to install (default "ufawkes-lsp").
ARG LSP_PLUGINS="ufawkes-lsp"
COPY --chown=dev:dev .devcontainer/claude-plugins /home/dev/.local/share/ufawkes-claude-plugins
RUN claude plugin marketplace add /home/dev/.local/share/ufawkes-claude-plugins \
  && for p in ${LSP_PLUGINS}; do claude plugin install "${p}@ufawkes" --scope user; done \
  && claude mcp add --scope user qmd -- qmd mcp

# Hook environments for this repo's .pre-commit-config.yaml, installed as dev
# into ~/.cache/pre-commit, so postCreateCommand's install-hooks finds them all
# and downloads nothing (≈ 1.3 GB, incl. Go toolchains for gitleaks and
# actionlint, otherwise fetched by every new container). pre-commit keys its
# cache by repo + rev: a repo on the same revs reuses them, a bumped rev
# downloads only that hook. Last layer, so a hook change rebuilds only this one.
# pre-commit needs a git work tree as its cwd, and WORKDIR would create it root-owned.
COPY --chown=dev:dev .pre-commit-config.yaml /tmp/pre-commit-config.yaml
# hadolint ignore=DL3003
RUN d="$(mktemp -d)" \
  && mv /tmp/pre-commit-config.yaml "$d/.pre-commit-config.yaml" \
  && git init -q "$d" \
  && (cd "$d" && for i in 1 2 3; do pre-commit install-hooks && break || { echo "Retry $i/3..."; sleep $((i * 10)); }; done) \
  && rm -rf "$d" "$HOME/.cache/go-build" "$HOME/.cache/pip" "$HOME/.npm/_cacache"

# Declares the editor setup with the image, so any repo using fawkes-space gets
# the agent extensions without copying them; devcontainer.json merges over it.
LABEL devcontainer.metadata='[{"remoteUser":"dev","customizations":{"vscode":{"extensions":["anthropic.claude-code","sst-dev.opencode"]}}}]'
