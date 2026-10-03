# syntax=docker/dockerfile:1
# uFawkesAI devcontainer image — the shared image for the uFawkes suite and fawkes.
# Published to ghcr.io/paruff/fawkes-space-devcontainer by build-devsecops-images.yml.
#
# The ai base already includes: OpenCode, qmd, the language servers (TS/JS,
# Python, Bash, YAML; the polyglot base adds Java), Superpowers + qmd agent skills
# (linked into ~/.claude/skills and ~/.config/opencode/skills), pre-commit,
# gh, the core scanners, zsh, sudo, and the dev user.

ARG BASE_IMAGE=ghcr.io/paruff/fawkes-space-ai:latest
FROM ${BASE_IMAGE}

# Claude Code from npm (licence reserves all rights — not baked in the base image).
# The base sets NPM_CONFIG_PREFIX to a dev-owned dir, so no sudo is needed.
ARG CLAUDE_CODE_VERSION=2.1.283
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
  && npm cache clean --force

# Code intelligence + qmd for Claude Code. The language servers and qmd ship in
# the ai base; the local ufawkes-lsp plugin (.devcontainer/claude-plugins) tells
# Claude Code how to start them, and qmd is a user-scope MCP server so every
# repo opened in this container gets it.
# LSP_PLUGINS: "ufawkes-lsp" by default; the polyglot build adds
# "ufawkes-lsp-java" (its base image is the only one with jdtls).
ARG LSP_PLUGINS="ufawkes-lsp"
COPY --chown=dev:dev .devcontainer/claude-plugins /home/dev/.local/share/ufawkes-claude-plugins
RUN claude plugin marketplace add /home/dev/.local/share/ufawkes-claude-plugins \
  && for p in ${LSP_PLUGINS}; do claude plugin install "${p}@ufawkes" --scope user; done \
  && claude mcp add --scope user qmd -- qmd mcp
