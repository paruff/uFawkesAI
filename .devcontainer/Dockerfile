# syntax=docker/dockerfile:1
# uFawkesAI devcontainer image — the shared image for the uFawkes suite and fawkes.
# Published to ghcr.io/paruff/ufawkesai-devcontainer by build-devsecops-images.yml.
#
# The ai base already includes: OpenCode, Superpowers + Flux agent skills
# (linked into ~/.claude/skills and ~/.config/opencode/skills), pre-commit,
# gh, the core/gitops scanners, zsh, sudo, and the dev user.

ARG BASE_IMAGE=ghcr.io/paruff/ufawkes-devsecops-ai:latest
FROM ${BASE_IMAGE}

# Claude Code from npm (licence reserves all rights — not baked in the base image).
# The base sets NPM_CONFIG_PREFIX to a dev-owned dir, so no sudo is needed.
ARG CLAUDE_CODE_VERSION=2.1.283
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
  && npm cache clean --force
