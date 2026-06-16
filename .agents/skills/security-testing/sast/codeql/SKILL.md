---
name: codeql-analysis
description: "Run CodeQL queries to detect deep security vulnerabilities. Use when building CodeQL database, running language-specific queries, or validating results."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CodeQL Analysis

> **Load trigger:** `"load codeql-analysis skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Run CodeQL queries to detect deep security vulnerabilities.

## Responsibilities

- Build CodeQL database
- Run language-specific queries
- Validate results

## Inputs

- Source code

## Outputs

- `codeql.sarif`

## Language Queries

| Language              | Query Pack                 | Focus                     |
| --------------------- | -------------------------- | ------------------------- |
| JavaScript/TypeScript | `js-security-extended`     | Injection, auth, crypto   |
| Python                | `python-security-extended` | Injection, path traversal |
| Go                    | `go-security-extended`     | Injection, SSRF, crypto   |

## Query Suites

| Suite                  | Coverage                |
| ---------------------- | ----------------------- |
| `security-extended`    | Broad security coverage |
| `security-and-quality` | Security + code quality |

## Validation Rules

- [ ] Database built successfully
- [ ] All query suites executed
- [ ] No critical CodeQL findings
- [ ] SARIF output valid

## Output Format

```json
{
  "skill": "codeql-analysis",
  "status": "pass | fail",
  "languages": ["typescript", "python"],
  "findings": {
    "critical": 0,
    "high": 0,
    "medium": 2,
    "low": 4
  },
  "results": []
}
```

## Success Criteria

- No critical CodeQL findings
- All languages analyzed
