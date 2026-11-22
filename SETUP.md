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
