---
name: env-generation
description: "Generate .env files for local development. Use when creating .env.local, populating required variables, or validating secrets are not committed."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Environment File Generation

> **Load trigger:** `"load env-generation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate `.env` files for local development.

## Responsibilities

- Create `.env.local` from template
- Populate required variables
- Validate secrets are not committed
- Validate `.env.local` in `.gitignore`

## Inputs

- `.env.example` or `.env.template`
- Project config

## Outputs

- `.env.local`

## Variable Categories

| Category      | Example        | Required |
| ------------- | -------------- | -------- |
| Database      | `DATABASE_URL` | Yes      |
| API Keys      | `API_KEY`      | Yes      |
| Service URLs  | `SERVICE_URL`  | Yes      |
| Feature Flags | `FEATURE_X`    | No       |
| Debug         | `DEBUG`        | No       |

## Validation Rules

- [ ] `.env.example` exists with all required variables
- [ ] `.env.local` generated with placeholders
- [ ] `.env.local` in `.gitignore`
- [ ] No real secrets in committed files
- [ ] All required variables documented

## Output Format

```json
{
  "skill": "env-generation",
  "status": "success",
  "template": ".env.example",
  "output": ".env.local",
  "variables": {
    "required": 5,
    "populated": 5,
    "optional": 3
  },
  "in_gitignore": true
}
```

## Success Criteria

- Valid `.env.local` generated
- All required variables present
- Secrets not committed
