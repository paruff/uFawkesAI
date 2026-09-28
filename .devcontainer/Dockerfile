# syntax=docker/dockerfile:1
# uFawkesAI devcontainer image — builds from the DevSecOps "ai" stage
# Published to ghcr.io/paruff/ufawkesai-devcontainer:latest on tag push

ARG BASE_IMAGE=ghcr.io/paruff/ufawkesai/ufawkes-devsecops-ai:latest
FROM ${BASE_IMAGE}

# Devcontainer-specific customizations
# The ai stage already includes: opencode, git, zsh, sudo, vim-tiny, less, dev user

# Install Claude Code from npm (licence reserves all rights — not baked in base image)
ARG CLAUDE_CODE_VERSION=2.1.283
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
  && npm cache clean --force

# Install any additional npm globals needed for this repo
ARG OPENCODE_VERSION=1.18.32
RUN npm install -g opencode-ai@${OPENCODE_VERSION} \
  && npm cache clean --force

# Ensure dev user owns npm global prefix
ENV NPM_CONFIG_PREFIX=/home/dev/.npm-global
ENV PATH=/home/dev/.npm-global/bin:$PATH

# The base image already sets USER dev and WORKDIR /home/dev
# No additional CMD needed — inherits zsh from ai stage
