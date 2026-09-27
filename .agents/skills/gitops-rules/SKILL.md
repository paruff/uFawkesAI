---
name: gitops-rules
description: "GitOps and collaboration conventions for this repo: branch naming, commit format, PR requirements, and merge strategy. Use when creating branches, writing commits, or opening/reviewing pull requests."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# GitOps and Collaboration Rules

- Branch naming: `feat/*`, `fix/*`, `chore/*`, `docs/*`, `refactor/*`, `test/*`.
- Commit format: Conventional Commits (`type(scope): description`).
- PRs must include summary, verification evidence, risk notes, and rollback plan.
- Keep changes scoped and traceable to intent/spec/plan artifacts.
- Merge strategy: prefer squash merge unless repository policy requires otherwise.
