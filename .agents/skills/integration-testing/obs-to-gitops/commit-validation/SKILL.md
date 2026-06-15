---
name: gitops-commit-validation
description: "Validate that OBS produces correct Git commits. Use when validating commit messages, file structure, or diff correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Commit Validation

> **Load trigger:** `"load gitops-commit-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that OBS produces correct Git commits.

## Responsibilities

- Validate commit messages
- Validate file structure
- Validate diff correctness

## Inputs

- GitOps repo

## Outputs

- `commit-validation.json`

## Commit Message Convention

```
chore(deploy): update <service> to <version>

- Updated image tag to v1.3.0
- Updated image digest to sha256:abc123
- Affected environments: dev, staging, prod
```

## Validation Rules

- [ ] Commit message follows convention
- [ ] Files changed correctly
- [ ] Diff shows correct changes
- [ ] No unintended changes
- [ ] Commit signed (if required)

## Output Format

```json
{
  "skill": "gitops-commit-validation",
  "status": "pass | fail",
  "commit": {
    "sha": "abc123",
    "message_valid": true,
    "files_changed": 3,
    "diff_correct": true,
    "unintended_changes": 0
  }
}
```

## Success Criteria

- Correct commit structure
- Commit message follows convention
- No unintended changes
