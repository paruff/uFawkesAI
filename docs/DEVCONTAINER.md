# Dev Container — Reproducible Development Environment

This repository includes a Dev Container definition at `.devcontainer/devcontainer.json`
so contributors can open the project in GitHub Codespaces or VS Code Dev Containers
with a consistent environment and no manual machine setup.

---

## What the dev container provides

- Base image: `mcr.microsoft.com/devcontainers/javascript-node:22`
- Node.js 22 from the base image
- GitHub CLI preinstalled via Dev Container features
- Zsh + Oh My Zsh enabled for a ready-to-use shell experience
- Opinionated VS Code extension set for Copilot, PR review, linting, and formatting
- `postCreateCommand` that runs:
  - `npm ci`
  - `./scripts/setup.sh` (symlink and local setup bootstrap)

This gives every contributor the same starting state for local development.

---

## How to use it

### GitHub Codespaces
1. Click the "Open in GitHub Codespaces" badge in `README.md`.
2. Wait for the environment to build.
3. Start working immediately.

### VS Code Dev Containers
1. Install the "Dev Containers" extension in VS Code.
2. Open the repository folder.
3. Run: **Dev Containers: Reopen in Container**.

---

## How to customize for your project

If you fork this template, update `.devcontainer/devcontainer.json` to match your stack:

- **Image/runtime**: switch the image or feature versions (Node, Python, etc.)
- **Features**: add tools your team needs (database CLIs, language toolchains)
- **Extensions**: keep only editor extensions your workflow actually uses
- **postCreateCommand**: install dependencies and run any setup scripts required for your project
- **forwardPorts**: expose local app/server ports when needed

Keep changes minimal and reproducible so every contributor gets the same behavior.

---

## DORA capability mapping

This implements **DORA AI Capability 7: Quality Internal Platform** by providing a
consistent, low-friction development environment. It directly supports "developer
independence" by reducing setup variation and onboarding time.
