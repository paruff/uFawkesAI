---
name: ci-secrets
description: "Ensure all required secrets are available and correctly scoped. Use when validating registry credentials, GitOps tokens, signing keys, or cloud provider tokens."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Secret & Token Validation

> **Load trigger:** `"load ci-secrets skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all required secrets are available and correctly scoped.

## Responsibilities

- Validate registry credentials
- Validate GitOps repo tokens
- Validate signing keys (Cosign)
- Validate cloud provider tokens (if applicable)

## Inputs

- CI secrets (from GitHub Actions, etc.)

## Outputs

- `secret-validation.json`

## Required Secrets

| Secret | Purpose | Required |
|--------|---------|----------|
| `REGISTRY_USERNAME` | Container registry auth | If pushing images |
| `REGISTRY_PASSWORD` | Container registry auth | If pushing images |
| `GITOPS_TOKEN` | GitOps repo access | If updating GitOps |
| `COSIGN_KEY` | Artifact signing | If signing |
| `COSIGN_PASSWORD` | Artifact signing | If signing |
| `CLOUD_CREDENTIALS` | Cloud provider access | If deploying |

## Validation Rules

- [ ] All required secrets present
- [ ] Secrets not empty
- [ ] Secrets correctly scoped (not over-privileged)
- [ ] Secrets not logged or exposed

## Output Format

```json
{
  "skill": "ci-secrets",
  "status": "pass | fail",
  "secrets": [
    {"name": "REGISTRY_USERNAME", "present": true, "scoped": true},
    {"name": "COSIGN_KEY", "present": true, "scoped": true}
  ],
  "missing": [],
  "warnings": []
}
```

## Success Criteria

- All required secrets available
- Secrets correctly scoped
- No secrets exposed
