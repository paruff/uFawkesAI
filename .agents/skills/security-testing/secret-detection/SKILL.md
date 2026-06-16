---
name: secret-detection
description: "Ensure no secrets leak into source code, logs, artifacts, or GitOps repos. Use when scanning source code, Git history, container layers, or validating artifact integrity."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Secret Detection & Artifact Integrity

> **Load trigger:** `"load secret-detection skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure no secrets leak into source code, logs, artifacts, or GitOps repos.

## Responsibilities

- Scan source code for secrets
- Scan Git history
- Scan container layers
- Validate artifact integrity

## Inputs

- Source code
- Git repo
- Container image

## Outputs

- `secrets.json`
- `integrity.json`

## Sub-Skills

| Skill                        | Purpose                       |
| ---------------------------- | ----------------------------- |
| `secret-detection/gitleaks`  | Gitleaks secret scanning      |
| `secret-detection/integrity` | Artifact integrity validation |

## Secret Types Detected

| Type          | Pattern                     |
| ------------- | --------------------------- |
| API Keys      | `api[_-]?key`, `apikey`     |
| Tokens        | `token`, `bearer`, `jwt`    |
| Passwords     | `password`, `passwd`, `pwd` |
| Private Keys  | `BEGIN.*PRIVATE KEY`        |
| AWS Keys      | `AKIA[0-9A-Z]{16}`          |
| GitHub Tokens | `ghp_[0-9a-zA-Z]{36}`       |
| Slack Tokens  | `xox[baprs]-[0-9a-zA-Z-]+`  |

## Validation Rules

- [ ] No secrets in source code
- [ ] No secrets in Git history
- [ ] No secrets in container layers
- [ ] All artifacts integrity-verified
- [ ] Secrets documented if false positive

## Output Format

```json
{
  "skill": "secret-detection",
  "status": "pass | fail",
  "gitleaks": { "findings": 0, "critical": 0 },
  "container_secrets": 0,
  "artifacts_verified": 5,
  "issues": []
}
```

## Success Criteria

- No secrets found
- All artifacts integrity-verified
