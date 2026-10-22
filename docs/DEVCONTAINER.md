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
checks that the hooks are ready offline (`build-cde-space-image.yml`).

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

## Optional: AWS AI-DLC

The `ai` image ships [AI-DLC](https://github.com/awslabs/aidlc-workflows)
(`aidlc`, MIT-0) at a pinned, checksum-verified version. It is **off by
default**: the image and this template contain no AI-DLC files until you
opt in, per repo.

AI-DLC is a second lifecycle (its own agents, stages and `aidlc/` artifact
folder) beside this template's `intent → spec → plan` chain, which stays the
default and the gate. Whether the two should merge is undecided; try it on a
branch first.

```bash
aidlc config --harness claude --dry-run   # or --harness opencode: lists every file it would write
aidlc config --harness claude             # writes them
aidlc doctor                              # checks the result
```

A run writes `aidlc/`, a harness tree under `.claude/` (or `.opencode/`),
hooks in `.claude/settings.json`, and lines in `AGENTS.md`. `AI_STANCE.md`
requires human sign-off for changes to those governed paths, so opting in is
a person's decision, never an agent's.

## DORA capability mapping

This implements **AI Capability 7: Quality internal platforms** by providing a
consistent, low-friction development environment. It directly supports "developer
independence" by reducing setup variation and onboarding time.
