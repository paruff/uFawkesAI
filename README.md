# uFawkesAI

An implementation of Anthropic's [AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook)
(Claxton, 2026): six stages, each ending in a committed artifact, built on the
[Superpowers](https://github.com/obra/superpowers) skill suite. It ships as a template and as a signed devcontainer image
(`fawkes-space`) with Claude Code, OpenCode, Codex and Gemini CLI installed.

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

## The six stages

Each stage commits an artifact the next stage reads, so the commit history is the audit trail. Agents never approve their
own work or merge their own PRs; a human code owner does.

| Stage | Artifact | Superpowers skill | Where it lives here |
| --- | --- | --- | --- |
| 1. Plan | `docs/ai-sdlc/<feature>/intent.md` | `brainstorming` | `discovery` skill, `@planner`, `/plan` |
| 2. Design | `spec.md` | `brainstorming` | `@planner`; CI requires an `intent.md` beside every `spec.md` |
| 3. Build | `plan.md`, then the diff | `writing-plans`, `test-driven-development`, `subagent-driven-development` | `@builder`, `/implement`, `/tdd` |
| 4. Test | tests, builds, eval results | `verification-before-completion`, `systematic-debugging` | `@verifier`, `/verify`; `agent-config-ci.yml` replays evals when agent configuration changes |
| 5. Deploy | PR with review findings | `requesting-code-review`, `finishing-a-development-branch` | `REVIEW.md`, the `review-local` command before commit, `@operator`, `/ship`; a human merges |
| 6. Maintain | an incident or metric that becomes the next `intent.md` | `systematic-debugging` | `/release` files the follow-up issue; the metrics live in uFawkesObs |

Stage 6 is partial: the loop back into `intent.md` is manual today.

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

## Playbook components

| Component (from the playbook) | Where it lives |
| --- | --- |
| `CLAUDE.md` project knowledge | `AGENTS.md`, with `CLAUDE.md` and other harness files as symlinks |
| Skills | `.agents/skills/` and the Superpowers suite baked into the image |
| Hooks | `.pre-commit-config.yaml`, `.claude/settings.json`, `scripts/hooks/protected-paths.json` |
| Subagents | `.agents/agents/` (four agents: planner, builder, verifier, operator) |
| Evals | `.agents/evals/`, run by `agent-config-ci.yml` |
| `REVIEW.md` | `REVIEW.md`; applied locally by the `review-local` command |
| Sandbox | `.devcontainer/devcontainer.json` using `ghcr.io/paruff/fawkes-space` (non-root) |

## Container images

Built, signed (cosign, keyless) and published by `build-cde-space-image.yml` on every `v<semver>` tag.

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

AWS's [AI-DLC](https://github.com/awslabs/aidlc-workflows) is installed in the image as an opt-in alternative lifecycle; nothing is configured until you run `aidlc config`.

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
