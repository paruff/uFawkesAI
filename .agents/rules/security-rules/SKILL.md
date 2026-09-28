---
name: security-rules
description: "Security conventions for this repo: trust boundaries, protected files that must never be edited or committed, secret handling, and input validation. Use when touching auth, permissions, data handling, dependencies, or any file that might contain credentials."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Security Rules

- Respect trust boundaries at all inputs, outputs, and external integrations.
- Never edit or commit protected files: `.env`, `*.pem`, `*.key`, `credentials.*`, `.git/` internals.
- Do not log secrets, tokens, or sensitive identifiers.
- Validate and sanitize untrusted input at boundaries.
- Require focused security review for auth, permissions, data handling, and dependency changes.
