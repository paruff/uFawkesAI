---
name: sast
description: "Detect insecure code patterns, vulnerabilities, and misconfigurations in OBS, PIPE, and Fawkes services. Use when running Semgrep, CodeQL, or validating secure coding patterns."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Static Application Security Testing (SAST)

> **Load trigger:** `"load sast skill"` > **DORA:** Cap 1 (AI Policy) + Cap 6 (Operational Visibility)
> **Token cost:** Low

## Purpose

Detect insecure code patterns, vulnerabilities, and misconfigurations in OBS, PIPE, and Fawkes services.

## Responsibilities

- Run Semgrep rulesets
- Run CodeQL analysis
- Validate security hotspots
- Validate secure coding patterns

## Inputs

- Source code
- Semgrep config
- CodeQL database

## Outputs

- `sast.sarif`
- `sast-report.json`

## Sub-Skills

| Skill          | Purpose                   |
| -------------- | ------------------------- |
| `sast/semgrep` | Semgrep ruleset execution |
| `sast/codeql`  | CodeQL deep analysis      |

## Severity Levels

| Severity | Action                      |
| -------- | --------------------------- |
| Critical | Block merge, immediate fix  |
| High     | Block merge, fix within 24h |
| Medium   | Warn, fix within 1 week     |
| Low      | Log, fix in next sprint     |
| Info     | Log only                    |

## Validation Rules

- [ ] No critical or high vulnerabilities
- [ ] No unsafe patterns in core logic
- [ ] SARIF output valid
- [ ] All findings triaged

## Tools

- Semgrep
- CodeQL

## Output Format

```json
{
  "skill": "sast",
  "status": "pass | fail",
  "semgrep": { "findings": 0, "critical": 0, "high": 0 },
  "codeql": { "findings": 0, "critical": 0, "high": 0 },
  "total_findings": 0,
  "blocked": false
}
```

## Success Criteria

- No critical or high vulnerabilities
- No unsafe patterns in core logic
