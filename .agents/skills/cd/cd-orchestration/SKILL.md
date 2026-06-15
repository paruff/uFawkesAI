---
name: cd-orchestration
description: "Coordinate the flow of artifacts from CI to OBS to GitOps to cluster. Use when reading pipeline-spec delivery sections, triggering updates, or validating delivery prerequisites."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Delivery Pipeline Orchestration

> **Load trigger:** `"load cd-orchestration skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Coordinate the flow of artifacts from CI → OBS → GitOps → cluster.

## Responsibilities

- Read pipeline-spec delivery section
- Determine delivery targets (dev, stage, prod)
- Trigger OBS updates
- Trigger GitOps reconciliations
- Validate delivery prerequisites

## Inputs

- `version.json`
- `pipeline-spec.yaml`
- GitOps repo

## Outputs

- `delivery-orchestration.json`
- `delivery-plan.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `cd-orchestration/prerequisites` | Validate all conditions before delivery |
| `cd-orchestration/plan-generation` | Generate deterministic delivery plan |

## Delivery Flow

```
1. CI completes → artifacts signed, SBOM generated
2. Validate prerequisites (signatures, SBOM, version.json)
3. Generate delivery plan (targets, strategy, order)
4. Update OBS (observability metadata)
5. Update GitOps overlays (image tags, digests)
6. Trigger reconciliation (Flux/ArgoCD)
7. Validate delivery (health checks)
```

## Delivery Targets

| Environment | Approval | Strategy |
|-------------|----------|----------|
| dev | Automated | Rolling |
| staging | Automated | Rolling/Canary |
| production | Manual | Canary/Blue-Green |

## Rules

- [ ] Prerequisites validated before delivery
- [ ] Delivery plan generated before execution
- [ ] Each environment validated before next
- [ ] Rollback triggered on failure

## Success Criteria

- Delivery pipeline executes in correct order
- All prerequisites validated
- Health maintained throughout
