---
name: integration-testing
description: "Integration testing validating component boundaries (PIPE-to-OBS, OBS-to-GitOps, GitOps-to-Controller) and full-stack flow."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Integration Testing

> **Load trigger:** `"load integration-testing skill"`
> **DORA:** Cap 5 (Small Batches)
> **Token cost:** Medium

## Purpose

Validate integration between components (PIPE-to-OBS, OBS-to-GitOps, GitOps-to-Controller) and full-stack flow.

## Responsibilities

- Validate PIPE to OBS artifact flow
- Validate OBS to GitOps manifest updates
- Validate GitOps to controller reconciliation
- Test full-stack integration end-to-end
- Verify smoke tests pass

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `integration-testing/full-stack` | Validate entire OBS + PIPE + GitOps + K8s flow |
| `integration-testing/gitops-to-controller` | Validate Flux/ArgoCD reconciliation |
| `integration-testing/obs-to-gitops` | Validate OBS writes correct manifests |
| `integration-testing/pipe-to-obs` | Validate artifact flow from PIPE to OBS |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Tests build output integration |
| `delivery` | Validates deployment integration |

## Output Format

```json
{
  "skill": "integration-testing",
  "status": "pass | fail",
  "flows": {
    "pipe_to_obs": "pass",
    "obs_to_gitops": "pass",
    "gitops_to_controller": "pass",
    "full_stack": "pass"
  },
  "smoke_tests": {
    "passed": 12,
    "failed": 0
  }
}
```
