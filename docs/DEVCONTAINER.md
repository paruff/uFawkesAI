# Dev Container — Reproducible Development Environment

This repository includes a Dev Container definition at `.devcontainer/devcontainer.json`
so contributors can open the project in GitHub Codespaces or VS Code Dev Containers
with a consistent environment and no manual machine setup.

---

## What the dev container provides

- Image: `ghcr.io/paruff/fawkes-space` (built from `.devcontainer/Dockerfile` on
  the `fawkes-space-ai` image; see `images/devsecops/` and
  `docs/ai-sdlc/devsecops-image/spec.md`), user `dev`, zsh
- Agent harnesses: Claude Code, OpenCode, Codex and Gemini CLI, with the
  Superpowers and qmd skills, the four uFawkesAI agents and the language servers
- The pinned linters and scanners the hooks call (gitleaks, actionlint,
  shellcheck, shfmt, ruff, yamllint, markdownlint, trivy, …)
- **Every pre-commit hook environment for this repo's `.pre-commit-config.yaml`,
  baked into `~/.cache/pre-commit`**, so a new container installs no hooks
- VS Code extensions: Claude Code, OpenCode, Copilot Chat, GitHub Pull
  Requests, ESLint, Prettier, Code Spell Checker. The image's
  `devcontainer.metadata` label carries the Claude Code and OpenCode
  extensions, so any repo using the image gets them.
- `postCreateCommand`: `pre-commit install && pre-commit install-hooks &&
  bash scripts/shift-left.sh doctor`. With the baked cache, `install-hooks`
  takes about a second and needs no network.

---

## Start time

| Step at container create | Before | Now |
| --- | --- | --- |
| `pre-commit install-hooks` | ≈ 5 min, 1.3 GB downloaded (incl. Go toolchains to build gitleaks and actionlint) | ≈ 1 s, offline |
| Extensions | installed by VS Code on attach | unchanged (see below) |

pre-commit caches by hook repo + rev. A repo whose `.pre-commit-config.yaml`
bumps a rev downloads only that hook, once. Every PR that touches
`.pre-commit-config.yaml` or `.devcontainer/` rebuilds the image layer and
checks that the hooks are ready offline (`build-devsecops-images.yml`).

VS Code extensions are still downloaded when VS Code attaches: VS Code and
Codespaces keep them in different server directories, so the image can't hold
them for both. To cut that time, use Codespaces prebuilds, or keep the Dev
Containers extension cache (on by default).

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

- **Image**: pin `fawkes-space` by digest, or build your own from `.devcontainer/Dockerfile`
- **Hooks**: rebuild the image after changing `.pre-commit-config.yaml` so
  the baked hook environments match
- **Extensions**: keep only editor extensions your workflow actually uses
- **postCreateCommand**: install dependencies and run any setup scripts required for your project
- **forwardPorts**: expose local app/server ports when needed

Keep changes minimal and reproducible so every contributor gets the same behavior.

---

## DORA capability mapping

This implements **AI Capability 7: Quality internal platforms** by providing a
consistent, low-friction development environment. It directly supports "developer
independence" by reducing setup variation and onboarding time.
