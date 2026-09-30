# Rule: Security

> Always loaded (`.claude/rules/` in Claude Code, `instructions` in `opencode.json`).
> Applies when: auth, permissions, data handling, dependencies, credentials.

- Respect trust boundaries at all inputs, outputs, and external integrations.
- Never edit or commit protected files: `.env`, `*.pem`, `*.key`, `credentials.*`, `.git/` internals.
- Do not log secrets, tokens, or sensitive identifiers.
- Validate and sanitize untrusted input at boundaries.
- Require focused security review for auth, permissions, data handling, and dependency changes.
