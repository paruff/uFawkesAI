---
name: cluster-sim
description: "Run a local Kubernetes cluster for development and testing. Use when starting kind/k3d, applying manifests, validating rollout, or checking logs."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Local Cluster Simulation

> **Load trigger:** `"load cluster-sim skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Run a local Kubernetes cluster for development and testing.

## Responsibilities

- Start kind/k3d cluster
- Apply manifests
- Validate rollout
- Validate logs and metrics

## Inputs

- Manifests
- Local cluster config

## Outputs

- `cluster-sim.json`

## Cluster Options

| Tool | Use When |
|------|----------|
| kind | Full K8s simulation, CI testing |
| k3d | Lightweight, fast startup |
| minikube | Single-node development |

## Setup Commands

### kind

```bash
kind create cluster --name dev --wait 60s
kind export kubeconfig --name dev
```

### k3d

```bash
k3d cluster create dev --agents 2
```

## Validation Rules

- [ ] Cluster starts successfully
- [ ] All nodes Ready
- [ ] System pods Running
- [ ] Manifests apply cleanly
- [ ] Pods reach Running state

## Output Format

```json
{
  "skill": "cluster-sim",
  "tool": "kind",
  "cluster_name": "dev",
  "status": "running",
  "nodes": 1,
  "system_pods": {
    "total": 12,
    "running": 12
  },
  "manifests_applied": 5,
  "pods_running": 3
}
```

## Success Criteria

- Local cluster behaves like production
- Fast startup (< 60 seconds)
- Manifests apply cleanly
