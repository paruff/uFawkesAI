---
name: blue-green
description: "Deploy a new version alongside the old one and switch traffic atomically. Use when deploying green environment, validating health, switching traffic, or decommissioning blue."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Blue-Green Delivery

> **Load trigger:** `"load blue-green skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Deploy a new version alongside the old one and switch traffic atomically.

## Responsibilities

- Deploy green environment
- Validate green health
- Switch traffic from blue to green
- Decommission blue

## Inputs

- `version.json`
- Environment config

## Outputs

- `blue-green-report.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `blue-green/green-validation` | Validate green environment health |
| `blue-green/traffic-switch` | Switch traffic atomically |

## Delivery Steps

| Step | Action | Validation |
|------|--------|-----------|
| 1 | Deploy green | Pods running |
| 2 | Validate green | Health checks pass |
| 3 | Switch traffic | Traffic routed correctly |
| 4 | Monitor | Health maintained |
| 5 | Decommission blue | Resources freed |

## Rules

- [ ] Green validated before traffic switch
- [ ] Traffic switch is atomic
- [ ] Blue kept for rollback for 15 minutes
- [ ] Decommission only after validation period

## Tools

- Argo Rollouts
- kubectl
- Service selectors

## Success Criteria

- Zero-downtime switch
- Health maintained after switch
- Blue available for rollback
