---
name: risk-identification
description: "Identify risks early in the planning process. Use when assessing technical, architectural, security, and compliance risks before implementation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Risk Identification

> **Load trigger:** `"load risk-identification skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Identify risks early in the planning process.

## Responsibilities

- Identify technical risks
- Identify architectural risks
- Identify security risks
- Identify compliance risks
- Produce a risk report with mitigations

## Inputs

- `specification.md`
- `design.md`
- `tasks.json`

## Outputs

- `risk-report.json`

## Risk Categories

### Technical Risks

- [ ] New or unfamiliar technology stack
- [ ] Performance-sensitive code paths
- [ ] Concurrency or race condition potential
- [ ] Data migration or state transition risks
- [ ] External API availability or reliability

### Architectural Risks

- [ ] Changes to shared libraries or interfaces
- [ ] Breaking changes to public APIs
- [ ] Circular dependencies introduced
- [ ] Single points of failure added
- [ ] Scalability bottlenecks

### Security Risks

- [ ] Authentication or authorization changes
- [ ] Secret or credential handling
- [ ] Input validation requirements
- [ ] Data exposure risks
- [ ] Privilege escalation paths

### Compliance Risks

- [ ] Regulatory requirements affected
- [ ] Data residency or privacy concerns
- [ ] Audit trail requirements
- [ ] Policy violations introduced

## Risk Format

```json
{
  "risk_id": "RISK-NNN",
  "category": "technical | architectural | security | compliance",
  "severity": "high | medium | low",
  "description": "Description of the risk",
  "affected_tasks": ["TASK-001"],
  "mitigation": "Recommended mitigation strategy",
  "residual_risk": "What remains after mitigation"
}
```

## Success Criteria

- Risks are clearly identified and categorized
- Each risk has a mitigation strategy
- High-severity risks flagged for human review
