---
name: local-environment-simulation
description: "Simulate PIPE, OBS, GitOps, and cluster behavior locally for fast feedback loops. Use when running local pipeline simulations, GitOps updates, or cluster deployments."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Local Environment Simulation

> **Load trigger:** `"load local-environment-simulation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Simulate PIPE, OBS, GitOps, and cluster behavior locally for fast feedback loops.

## Responsibilities

- Run local PIPE simulation
- Run local OBS simulation
- Run local GitOps repo
- Run local kind/k3d cluster
- Validate local → GitOps → cluster flow

## Inputs

- Project repo
- Local simulation config

## Outputs

- `local-sim-report.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `local-environment-simulation/gitops-sim` | Simulate GitOps updates locally |
| `local-environment-simulation/cluster-sim` | Run local K8s cluster |

## Simulation Flow

```
1. Code change → local build
2. Build → local image
3. Image → local GitOps update
4. GitOps → local cluster reconcile
5. Cluster → validate deployment
```

## Tools

| Tool | Purpose |
|------|---------|
| kind | Local K8s cluster |
| k3d | Lightweight K8s cluster |
| Kustomize | Overlay rendering |
| Git CLI | Local GitOps |

## Rules

- [ ] Local simulation matches real pipeline behavior
- [ ] Fast feedback (< 5 minutes)
- [ ] No remote dependencies required
- [ ] Idempotent simulation

## Success Criteria

- Local simulation matches real pipeline behavior
- Fast iteration cycles
- No remote dependencies for basic flows
