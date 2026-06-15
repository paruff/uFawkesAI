---
name: token-scope
description: "Ensure CI/CD tokens and service accounts have minimal required permissions. Use when validating GitHub token scopes, registry tokens, or cluster service account scopes."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Token Scope Validation

> **Load trigger:** `"load token-scope skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure CI/CD tokens and service accounts have minimal required permissions.

## Responsibilities

- Validate GitHub token scopes
- Validate registry token scopes
- Validate cluster service account scopes

## Inputs

- Token metadata
- Service account definitions

## Outputs

- `token-scope.json`

## Validation Rules

### GitHub Tokens

| Scope | Required For | Risk If Unnecessary |
|-------|-------------|-------------------|
| `repo` | Code access | Full repo access |
| `write:packages` | Package publishing | Unnecessary write |
| `read:org` | Org membership | Information leak |
| `admin:repo_hook` | Webhook management | Event injection |

### Registry Tokens

- [ ] Tokens scoped to specific repositories
- [ ] Tokens have minimum required permissions (push vs admin)
- [ ] Tokens have expiration dates
- [ ] Tokens rotated regularly

### Cluster Service Accounts

- [ ] Service accounts limited to required namespaces
- [ ] No cluster-wide permissions unless required
- [ ] Token automounting disabled when not needed
- [ ] Bound to specific roles, not cluster-admin

## Output Format

```json
{
  "skill": "token-scope",
  "status": "pass | fail",
  "tokens_checked": 5,
  "violations": [
    {
      "token": "github-actions-token",
      "scope": "repo",
      "issue": "Full repo access granted, write access sufficient",
      "fix": "Reduce scope to write:packages"
    }
  ]
}
```

## Success Criteria

- No overprivileged tokens
- All tokens minimal scope
- Token expiration configured
