---
name: overlay-update
description: "Apply environment-specific manifest updates. Use when updating image tags, digests, configmaps, or validating overlay correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Environment Overlay Update

> **Load trigger:** `"load overlay-update skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Apply environment-specific manifest updates.

## Responsibilities

- Update image tag
- Update image digest
- Update configmaps/secrets
- Validate overlay correctness

## Inputs

- `overlays/` directory
- `version.json`

## Outputs

- `overlay-update.json`

## Update Methods

### Image Tag Update

```bash
yq -i '.spec.template.spec.containers[0].image = "my-app:v1.2.3" \
  overlays/<env>/deployment.yaml
```

### Image Digest Update

```bash
yq -i '.spec.template.spec.containers[0].image = "my-app:v1.2.3@sha256:abc123" \
  overlays/<env>/deployment.yaml
```

### ConfigMap Update

```bash
yq -i '.data.APP_VERSION = "v1.2.3" \
  overlays/<env>/configmap.yaml
```

### Validation

```bash
kustomize build overlays/<env> | kubectl apply --dry-run=client -f -
```

## Validation Rules

- [ ] Image tag follows naming convention
- [ ] Digest matches pushed image
- [ ] ConfigMap data valid
- [ ] Kustomize build succeeds
- [ ] No syntax errors in YAML

## Output Format

```json
{
  "skill": "overlay-update",
  "environment": "staging",
  "overlay_path": "overlays/staging/",
  "updates": [
    {"field": "image", "old": "my-app:v1.2.2", "new": "my-app:v1.2.3"},
    {"field": "configmap", "key": "APP_VERSION", "new": "v1.2.3"}
  ],
  "validation": "success"
}
```

## Success Criteria

- Correct overlay updates
- Validation passed
- Ready for commit
