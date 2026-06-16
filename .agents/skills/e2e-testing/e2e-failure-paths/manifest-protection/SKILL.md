---
name: invalid-manifest-protection
description: "Ensure invalid manifests never reach GitOps or the cluster. Use when simulating invalid Kustomize overlays, invalid Helm templates, or validating pipeline rejection."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Invalid Manifest Protection

> **Load trigger:** `"load invalid-manifest-protection skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Ensure invalid manifests never reach GitOps or the cluster.

## Responsibilities

- Simulate invalid Kustomize overlays
- Simulate invalid Helm templates
- Validate pipeline rejection

## Inputs

- Broken manifests

## Outputs

- `manifest-protection.json`

## Invalid Manifest Types

| Type                   | Example            | Expected Behavior |
| ---------------------- | ------------------ | ----------------- |
| Invalid YAML           | Malformed syntax   | Pipeline rejects  |
| Missing required field | Missing apiVersion | Pipeline rejects  |
| Invalid image tag      | Empty tag          | Pipeline rejects  |
| Schema violation       | Wrong field type   | Pipeline rejects  |
| Kustomize error        | Missing base       | Pipeline rejects  |

## Validation Rules

- [ ] Invalid manifests detected
- [ ] Pipeline rejects invalid manifests
- [ ] No invalid manifests reach GitOps
- [ ] Error messages clear

## Output Format

```json
{
  "skill": "invalid-manifest-protection",
  "status": "pass | fail",
  "tests": [
    { "type": "invalid_yaml", "rejected": true },
    { "type": "missing_field", "rejected": true },
    { "type": "invalid_tag", "rejected": true }
  ],
  "all_rejected": true
}
```

## Success Criteria

- Invalid manifests blocked
- No invalid manifests reach GitOps
