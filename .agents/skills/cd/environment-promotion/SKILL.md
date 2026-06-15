---
name: environment-promotion
description: "Promote artifacts across dev → stage → prod environments using GitOps. Use when updating overlays, image tags, configs, or committing GitOps changes."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Environment Promotion

> **Load trigger:** `"load environment-promotion skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Promote artifacts across dev → stage → prod environments using GitOps.

## Responsibilities

- Update environment overlays
- Update image tags and digests
- Validate environment-specific configs
- Commit and push GitOps changes

## Inputs

- `version.json`
- GitOps repo

## Outputs

- `promotion-report.json`
- `manifest-diff.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `environment-promotion/policy` | Enforce promotion rules and constraints |
| `environment-promotion/overlay-update` | Apply environment-specific manifest updates |

## Promotion Flow

```
1. Validate promotion policy (approvals, tests, freeze)
2. Update overlay (image tag, digest)
3. Validate overlay (kustomize build)
4. Commit and push
5. Trigger reconciliation
6. Validate deployment
```

## Overlay Update Rules

| Field | Update Method |
|-------|--------------|
| Image tag | `yq` set `.spec.template.spec.containers[0].image` |
| Digest | Append `@sha256:...` to image |
| ConfigMap | `yq` set data fields |
| Replicas | `yq` set `.spec.replicas` |

## Rules

- [ ] Policy validated before overlay update
- [ ] Overlay validated before commit
- [ ] Commit includes version in message
- [ ] Reconciliation triggered after push

## Success Criteria

- Correct GitOps updates for each environment
- Policy compliance ensured
- Audit trail maintained
