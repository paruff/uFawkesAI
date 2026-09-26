# Intent — Deterministic DevSecOps Toolchain Image

Status: ACCEPTED (originator: repo owner, 2026-09-26)

## Problem

Local verification and CI verification do not run the same tools:

- `.devcontainer/devcontainer.json` uses a floating base
  (`javascript-node:22`) and installs tools in `postCreateCommand`, so two
  contributors can build different environments on different days.
- CI workflows install tools per job (`pip install 'pre-commit==4.6.0'`,
  `pip install yamllint`, `actions/setup-*`), with different versions than a
  developer gets locally (e.g. apt shipped `pre-commit` 4.2.0 in the
  devcontainer on 2026-09-26).
- `pre-commit` downloads each hook's environment on first run (minutes,
  network required), so a hook can fail for reasons unrelated to the code.
- Missing tools are discovered late: `pre-commit` and `shellcheck` were both
  absent from the devcontainer, and `scripts/preflight.sh` blocked a push.

## Desired outcome

One versioned, signed container image that is the single source of
toolchain truth for:

1. local pre-commit hooks,
2. the devcontainer (VS Code / Codespaces),
3. CI/CD DevSecOps gates,

so "passed locally" means "passes in CI", and the same image can be adopted
by other repos that want GitOps and AI-native SDLC tooling.

## Decisions already made

- Image source and releases live **inside uFawkesAI** (not a separate repo).
- **Layered variants**: `core` → `gitops` → `ai`, each built `FROM` the
  previous one.
- **Spec + design review before any build work** (this document chain).

## Out of scope

- Language runtimes/toolchains for application code beyond what the
  verification tools themselves need (adopters extend the image).
- Hosting/secrets for MCP servers that need credentials.
- Replacing the vendored reusable workflows' logic — they are re-pointed at
  the image, not rewritten.
