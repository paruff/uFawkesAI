# uFawkesAI

A template for working with AI coding agents the way the DORA research describes
high-performing teams: one instruction file every agent reads, four agents with
clear boundaries, a documented intent → spec → plan chain, a review before commit,
and a signed devcontainer image with the tools installed.

[![MIT License](https://img.shields.io/badge/License-MIT-2EA44F?style=flat-square)](./LICENSE)

## What you get

- `AGENTS.md` — one page of instructions. `CLAUDE.md`, `GEMINI.md`, `.cursorrules` and
  `.github/copilot-instructions.md` are symlinks to it, so Claude Code, Gemini CLI, Cursor,
  Copilot and Codex all load the same file.
- `.agents/agents/` — four agents, each a boundary that can block, write or change repo state:
  `planner`, `builder`, `verifier`, `operator`.
- `.agents/commands/` and `.agents/skills/` — slash commands and on-demand skills, shared by
  Claude Code and OpenCode through symlinks.
- `REVIEW.md` — the review rubric. `/review-local` applies it before you commit; CI applies it again on the PR.
- `.devcontainer/` — uses the `fawkes-space` image (below): Claude Code, OpenCode, Codex, Gemini CLI,
  language servers, pre-commit and scanners.
- CI guardrails: PR size limit, artifact-chain check, agent evals, secret scan, documentation freshness.

## Lifecycle

```text
plan (@planner) → build (@builder) → verify (@verifier) → /review-local → ship (@operator) → CI agent review → human merges
```

A feature starts with `docs/ai-sdlc/<feature>/{intent,spec,plan}.md` (`/plan`); CI checks the chain.
Agents never merge their own PRs.

## Quick start

1. Click **Use this template** on GitHub, or clone the repo.
2. Run `./scripts/setup.sh` (creates symlinks, installs git hooks).
3. Replace the `[PLACEHOLDER]` sections in `AGENTS.md` with your project's facts.
4. Open the folder in VS Code and choose **Reopen in Container**.

## DORA AI Capabilities implemented

| DORA AI capability               | Where                                                 |
| -------------------------------- | ----------------------------------------------------- |
| Clear and communicated AI stance | `AI_STANCE.md`, `AGENTS.md`                           |
| Healthy data ecosystems          | `docs/CHANGE_IMPACT_MAP.md`, `docs/API_SURFACE.md`    |
| AI-accessible internal data      | `AGENTS.md` context index, `.vscode/settings.json`    |
| Strong version control practices | `ci-quality.yml` PR size check, `docs/COMMIT_CONVENTIONS.md` |
| Working in small batches         | 400-line PR limit, `docs/GOLDEN_PATH.md`              |
| User-centric focus               | `.agents/skills/discovery/SKILL.md`                   |
| Quality internal platforms       | `.devcontainer/devcontainer.json`, `.agents/agents/`  |

## Harness anatomy

The [AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) (Claxton, Anthropic, 2026-08-21)
names six parts of an agent harness. Here is where each lives:

| Component     | Provided by                                                                      |
| ------------- | -------------------------------------------------------------------------------- |
| Instructions  | `AGENTS.md` and its symlinks                                                     |
| Tools / MCP   | `.mcp.json`, `opencode.json`, `scripts/hooks/protected-paths.json`               |
| Sandbox       | `.devcontainer/devcontainer.json` using `ghcr.io/paruff/fawkes-space` (non-root) |
| Orchestration | `.agents/agents/`, `docs/MODEL_ROUTING_GUIDE.md`                                 |
| Hooks         | `.pre-commit-config.yaml`, `ci-quality.yml`                                      |
| Review        | `REVIEW.md`, `agent-review.yml`, and the `review-local` command                  |

## Container images

Built, signed (cosign, keyless) and published by `build-devsecops-images.yml` on every `v<semver>` tag.

| Image                      | Use                                                                          |
| -------------------------- | ---------------------------------------------------------------------------- |
| `ghcr.io/paruff/fawkes-space` | The devcontainer: core + Claude Code, OpenCode, Codex, Gemini CLI, language servers, qmd |
| `ghcr.io/paruff/fawkes-core`  | Linters, secret/vuln/SAST scanners and pre-commit only                       |

The devcontainer's base layer is the same package under the tag `base-X.Y.Z`.
Tags: `X.Y.Z`, `X.Y`, `X`, `latest`. Pin a version or digest from the Releases page and verify with
`cosign verify` (cosign v3 or later; the command is in each release's notes).

Host requirements: 2 CPUs and 4 GB of memory for the container. A smaller VM kills agent
sessions with no error. Colima: `colima start --cpu 4 --memory 8`.

## Works with

Claude Code, OpenCode, Codex, Gemini CLI, GitHub Copilot, Cursor, and anything else that reads `AGENTS.md`.

## Related repositories

[uFawkesPipe](https://github.com/paruff/uFawkesPipe) (CI/CD pipeline) and
[uFawkesObs](https://github.com/paruff/uFawkesObs) (observability and DORA dashboards).
See `docs/UFAWKES_INTEGRATION.md`.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Security issues: [SECURITY.md](./SECURITY.md).

## Research basis

- DORA, [_AI Capabilities Model_](https://dora.dev/ai/capabilities-model/report/) (2025): the seven capabilities above.
- DORA, [_2025 State of AI-assisted Software Development_](https://dora.dev/research/2025/dora-report/): AI amplifies what is already there.
- Anthropic, [_The AI-Native SDLC Playbook_](https://claude.com/blog/the-ai-native-sdlc-playbook) (2026): the artifact chain.

## License

MIT
