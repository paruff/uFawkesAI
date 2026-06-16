---
name: chaos-testing
description: "Chaos engineering for validating system resilience through controlled failure injection, cluster fault simulation, and GitOps drift scenarios."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Chaos Testing

> **Load trigger:** `"load chaos-testing skill"`
> **DORA:** Cap 6 (Reliability)
> **Token cost:** Medium

## Purpose

Validate system resilience through controlled failure injection, cluster fault simulation, and GitOps drift scenarios.

## Responsibilities

- Inject controlled failures (network, process, registry)
- Simulate node and pod failures
- Test failure modes and recovery
- Validate GitOps drift detection and correction
- Measure system behavior under chaos

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `chaos-testing/chaos-injection` | Inject controlled failures into PIPE, OBS, GitOps |
| `chaos-testing/cluster-chaos` | Validate K8s resilience under node/pod failures |
| `chaos-testing/failure-modes` | Test predictable failure scenarios |
| `chaos-testing/gitops-drift-chaos` | Introduce drift to validate detection/correction |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Tests build output resilience |
| `delivery` | Validates deployment resilience |

## Output Format

```json
{
  "skill": "chaos-testing",
  "status": "pass | fail",
  "experiments": [
    {
      "type": "network-latency",
      "target": "obs-pod",
      "result": "recovered",
      "duration_ms": 5000
    }
  ],
  "resilience_score": 85
}
```
