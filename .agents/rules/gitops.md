# Rule: GitOps

> Always loaded (`.claude/rules/` in Claude Code, `instructions` in `opencode.json`).
> Applies when: branching, committing, opening or reviewing a PR.

- Branch naming: `wip/*` only. This rule overrides `CONTRIBUTING.md` and `docs/PR_STANDARD.md`, which are out of date.
- Commit format: Conventional Commits (`type(scope): description`).
- PRs must include summary, verification evidence, risk notes, and rollback plan.
- Keep changes scoped and traceable to intent/spec/plan artifacts.
- Merge strategy: prefer squash merge unless repository policy requires otherwise.
