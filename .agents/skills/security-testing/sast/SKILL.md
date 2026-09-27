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

> **Load trigger:** `"load sast skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance + Core: Operational visibility
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

**This skill produces evidence only.** No workflow in this repository runs
Semgrep or CodeQL, so a finding here cannot block a merge on its own. Severity
sets the response SLA and whether a finding is marked blocking in the review
report; the deciding authority is a human reading that report.

| Severity | Response                                        |
| -------- | ----------------------------------------------- |
| Critical | Mark blocking in `review-report.md`; fix now     |
| High     | Mark blocking in `review-report.md`; fix in 24h  |
| Medium   | Warn, fix within 1 week                         |
| Low      | Log, fix in next sprint                         |
| Info     | Log only                                        |

To make this an enforced gate rather than advisory, add a SAST job to
`.github/workflows/agent-ci.yml` that exits non-zero on Critical and High, then
update this section. Until that job exists, "blocking" means "requires an
explicit human decision in the review report" — not "the merge is stopped".

**Enforcement: advisory.** No workflow in this repository runs Semgrep or
CodeQL. These criteria are reported, not enforced.

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
