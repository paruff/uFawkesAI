# AI-native loop setup

Adoption status of the playbook's plays in this project. `/sdlc-setup` updates it and resumes from whatever is pending.
Legend: ✅ done · ⬜ pending · ➖ not applicable

| Play | Status | Notes |
|---|---|---|
| Base config (`.sdlc/config.json`, `settings.json`) | ⬜ | |
| CLAUDE.md (< 1 page, verified commands) | ⬜ | |
| Feedback loop (build/test/lint with one command, green) | ⬜ | |
| Guardrails (protected paths, secrets, formatting, test-lock) | ⬜ | |
| Production gate | ⬜ | |
| Policies as skills | ⬜ | |
| REVIEW.md + automated review on PR/MR | ⬜ | |
| Tracker (Jira) | ⬜ | |
| Manual provider configuration (branch protection, secrets) | ⬜ | |
| Configuration evals in CI | ⬜ | |
| Stage 6: bands and closing the loop | ⬜ | Requires metrics with a stable baseline |

## Next step
Run `/sdlc-intent` for the first change.

## Superpowers (seam R8)
The loop requires these Superpowers skills (`.agents/agents/*.md` name them per stage): `brainstorming`, `writing-plans`, `test-driven-development`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `verification-before-completion`, `finishing-a-development-branch`.
- **Claude Code:** install the plugin at user level, `/plugin install superpowers@claude-plugins-official`, version **7.0.0** (the marketplace has no version pin: confirm `/plugin` lists it; the version pinned in `images/devsecops/tools.lock.json`).
- **OpenCode:** the `plugin` array in `opencode.json` pins `superpowers@git+https://github.com/obra/superpowers.git#v7.0.0`. `scripts/check-harness-parity.sh` fails if it is unpinned. Bump both together.

## Board mirror (seam R7)
`.github/workflows/board-mirror.yml` sets the Project #7 Status/Gate of the issue named by `issue:` in a change's `intent.md` front matter. Needs a repo secret `BOARD_TOKEN` (a PAT with `project` scope; `GITHUB_TOKEN` cannot write a user-owned project).
