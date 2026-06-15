---
name: gitleaks-secret-scanning
description: "Detect secrets in source code and Git history. Use when scanning working tree, scanning Git history, or validating findings."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Gitleaks Secret Scanning

> **Load trigger:** `"load gitleaks-secret-scanning skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Detect secrets in source code and Git history.

## Responsibilities

- Scan working tree
- Scan Git history
- Validate findings

## Inputs

- Git repo

## Outputs

- `gitleaks.json`

## Scan Commands

```bash
# Working tree only
gitleaks detect --source . --report-format json --report-path gitleaks.json

# Full Git history
gitleaks detect --source . --log-opts="--all" --report-format json --report-path gitleaks.json
```

## Validation Rules

- [ ] Working tree scanned
- [ ] Git history scanned
- [ ] No secrets found
- [ ] False positives documented
- [ ] `.gitleaksignore` updated if needed

## Output Format

```json
{
  "skill": "gitleaks-secret-scanning",
  "status": "pass | fail",
  "scan_scope": "full_history",
  "total_commits_scanned": 5000,
  "findings": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  },
  "details": []
}
```

## Success Criteria

- No secrets found in source code or history
