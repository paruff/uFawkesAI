---
name: semgrep-ruleset-execution
description: "Run Semgrep rulesets against Fawkes codebases. Use when executing OWASP rules, custom Fawkes rules, or validating findings."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Semgrep Ruleset Execution

> **Load trigger:** `"load semgrep-ruleset-execution skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Run Semgrep rulesets against Fawkes codebases.

## Responsibilities

- Execute OWASP rules
- Execute custom Fawkes rules
- Validate findings

## Inputs

- Semgrep config

## Outputs

- `semgrep.json`

## Rulesets

| Ruleset           | Purpose                      |
| ----------------- | ---------------------------- |
| `p/owasp-top-ten` | OWASP Top 10 vulnerabilities |
| `p/typescript`    | TypeScript security patterns |
| `p/python`        | Python security patterns     |
| `p/go`            | Go security patterns         |
| `p/dockerfile`    | Dockerfile best practices    |
| `p/kubernetes`    | K8s manifest security        |
| `fawkes/custom`   | Fawkes-specific patterns     |

## Fawkes Custom Rules

| Rule ID                     | Pattern                    | Severity |
| --------------------------- | -------------------------- | -------- |
| `fawkes-no-secrets-in-code` | Hardcoded API keys, tokens | Critical |
| `fawkes-no-plaintext-logs`  | Secrets in log statements  | High     |
| `fawkes-secure-env`         | Env vars with secrets      | Medium   |
| `fawkes-no-exec`            | `exec()` with user input   | High     |

## Validation Rules

- [ ] All rulesets executed
- [ ] No critical findings
- [ ] Findings triaged
- [ ] SARIF output valid

## Output Format

```json
{
  "skill": "semgrep-ruleset-execution",
  "status": "pass | fail",
  "rulesets_executed": 7,
  "findings": {
    "critical": 0,
    "high": 1,
    "medium": 3,
    "low": 5,
    "info": 2
  },
  "results": []
}
```

## Success Criteria

- No critical findings
- All findings documented
