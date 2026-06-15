---
name: image-tag-promotion
description: "Update image tags across environment overlays. Use when replacing tag in kustomization.yaml, validating digest, or validating manifest correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Image Tag Promotion

> **Load trigger:** `"load image-tag-promotion skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Update image tags across environment overlays.

## Responsibilities

- Replace tag in kustomization.yaml
- Validate digest
- Validate manifest correctness

## Inputs

- `version.json`

## Outputs

- Updated `kustomization.yaml`

## Update Command

```bash
yq -i '.images[0].newTag = "v1.3.0"' overlays/staging/kustomization.yaml
```

## Validation Rules

- [ ] Tag updated correctly
- [ ] Digest matches
- [ ] Manifest builds successfully
- [ ] No schema violations

## Output Format

```json
{
  "skill": "image-tag-promotion",
  "status": "success",
  "overlay": "staging",
  "old_tag": "v1.2.3",
  "new_tag": "v1.3.0",
  "digest": "sha256:abc123",
  "build": "pass"
}
```

## Success Criteria

- Correct tag applied
- Manifest builds successfully
