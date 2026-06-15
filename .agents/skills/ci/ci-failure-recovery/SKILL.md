---
name: ci-failure-recovery
description: "Detect, classify, and recover from CI failures automatically. Use when handling flaky tests, transient failures, or providing actionable diagnostics."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Failure Recovery

> **Load trigger:** `"load ci-failure-recovery skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Detect, classify, and recover from CI failures automatically.

## Responsibilities

- Detect flaky tests
- Retry transient failures
- Classify failure types
- Provide actionable diagnostics

## Inputs

- CI logs
- Test results

## Outputs

- `failure-report.json`
- `retry-plan.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-failure-recovery/flaky-tests` | Identify intermittently failing tests |
| `ci-failure-recovery/retry` | Retry transient failures with backoff |

## Failure Classification

| Type | Description | Action |
|------|-------------|--------|
| Transient | Network, registry, API timeout | Retry |
| Flaky | Test passes/fails inconsistently | Flag for fix |
| Deterministic | Code bug, config error | Report |
| Environment | Runner issue, resource limit | Retry with different runner |

## Classification Rules

### Transient Indicators

- [ ] Network timeout errors
- [ ] Registry rate limiting
- [ ] GitHub API failures
- [ ] OOM kills on runner

### Flaky Indicators

- [ ] Test passes on retry
- [ ] Test fails intermittently across runs
- [ ] No code change between pass/fail

### Deterministic Indicators

- [ ] Test always fails with same error
- [ ] Test fails after specific code change
- [ ] Compilation error

## Retry Strategy

| Failure Type | Max Retries | Backoff |
|-------------|-------------|---------|
| Network | 3 | Exponential |
| Registry | 3 | Exponential |
| Flaky test | 1 | None |
| Deterministic | 0 | N/A |

## Success Criteria

- Reduced false failures
- Accurate failure classification
- Actionable diagnostics provided
