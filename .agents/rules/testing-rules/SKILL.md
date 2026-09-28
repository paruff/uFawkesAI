---
name: testing-rules
description: "Testing conventions for this repo: verification gates before commit, coverage expectations, and never removing failing tests to make CI pass. Use when writing, changing, or reviewing tests, or before claiming a change is verified."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Testing Rules

- Run the project's verification gates before every commit: typecheck, lint, tests, and build.
- Add or update tests for every behavioral change.
- Prefer deterministic unit tests first; add integration/e2e only when required by scope.
- Coverage expectation: new/changed logic must be covered by meaningful assertions.
- Never remove failing tests to make CI pass; fix root causes.
