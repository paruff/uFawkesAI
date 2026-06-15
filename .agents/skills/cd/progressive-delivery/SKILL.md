---
name: progressive-delivery
description: "Roll out changes gradually with automated health checks and pause points. Use when defining progressive rollout steps, applying incremental traffic shifting, or validating health at each step."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Progressive Delivery

> **Load trigger:** `"load progressive-delivery skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Roll out changes gradually with automated health checks and pause points.

## Responsibilities

- Define progressive rollout steps
- Apply incremental traffic shifting
- Validate health at each step
- Pause or continue based on metrics

## Inputs

- `strategy-plan.json`
- Metrics

## Outputs

- `progressive-delivery.json`
- `step-status.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `progressive-delivery/stepwise` | Execute rollout in discrete steps |
| `progressive-delivery/pause-resume` | Auto-pause/resume based on metrics |

## Rollout Steps

| Step | Traffic | Duration | Health Check |
|------|---------|----------|--------------|
| 1 | 10% | 5 min | Latency, errors |
| 2 | 25% | 5 min | Latency, errors |
| 3 | 50% | 10 min | Latency, errors, saturation |
| 4 | 75% | 10 min | Latency, errors, saturation |
| 5 | 100% | - | Final validation |

## Rules

- [ ] Each step validated before proceeding
- [ ] Rollback on health check failure
- [ ] Pause on metric degradation
- [ ] Maximum 30 minutes total rollout time

## Tools

- Argo Rollouts
- Flagger
- Prometheus

## Success Criteria

- Safe, incremental rollout
- Zero-downtime deployment
- Automated health validation
