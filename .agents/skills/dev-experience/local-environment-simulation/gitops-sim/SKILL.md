---
name: gitops-sim
description: "Simulate GitOps updates locally without pushing to remote repos. Use when cloning GitOps repo locally, applying OBS updates, or validating manifest correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Local GitOps Simulation

> **Load trigger:** `"load gitops-sim skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Simulate GitOps updates locally without pushing to remote repos.

## Responsibilities

- Clone GitOps repo locally
- Apply OBS updates (image tag, digest)
- Validate manifest correctness
- Validate overlay builds

## Inputs

- GitOps repo (local clone)
- `version.json`

## Outputs

- `gitops-sim.json`

## Simulation Steps

### 1. Clone/Update GitOps Repo

```bash
git clone <gitops-repo> /tmp/local-gitops
cd /tmp/local-gitops
```

### 2. Apply OBS Updates

```bash
yq -i '.spec.template.spec.containers[0].image = "my-app:v1.2.3" \
  overlays/dev/deployment.yaml
```

### 3. Validate Overlay

```bash
kustomize build overlays/dev | kubectl apply --dry-run=client -f -
```

### 4. Commit (Local Only)

```bash
git add .
git commit -m "local: simulate OBS update"
```

## Validation Rules

- [ ] Overlay builds successfully
- [ ] Manifests valid YAML
- [ ] Image tag updated correctly
- [ ] No syntax errors

## Output Format

```json
{
  "skill": "gitops-sim",
  "status": "success",
  "gitops_repo": "/tmp/local-gitops",
  "overlay": "overlays/dev",
  "updates": [
    {"field": "image", "value": "my-app:v1.2.3"}
  ],
  "validation": "pass"
}
```

## Success Criteria

- Local GitOps updates match real behavior
- Manifests valid
- No remote push required
