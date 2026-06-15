---
name: cluster-state-snapshot
description: "Capture the full state of the cluster for drift comparison. Use when exporting all manifests, normalizing YAML, or removing volatile fields."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cluster State Snapshot

> **Load trigger:** `"load cluster-state-snapshot skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Capture the full state of the cluster for drift comparison.

## Responsibilities

- Export all manifests
- Normalize YAML
- Remove volatile fields

## Inputs

- Cluster

## Outputs

- `cluster-snapshot.yaml`

## Snapshot Command

```bash
# Export all resources in namespace
kubectl get all,configmap,secret,ingress -n fawkes -o yaml > cluster-snapshot.yaml
```

## Volatile Fields (Removed)

| Field | Reason |
|-------|--------|
| `metadata.resourceVersion` | Changes on every update |
| `metadata.uid` | Unique per resource |
| `metadata.creationTimestamp` | Not in Git |
| `status` | Not in Git |
| `metadata.managedFields` | Internal |

## Validation Rules

- [ ] All resources exported
- [ ] YAML normalized
- [ ] Volatile fields removed
- [ ] Snapshot stable for comparison

## Output Format

```json
{
  "skill": "cluster-state-snapshot",
  "status": "success",
  "namespace": "fawkes",
  "resources_exported": 50,
  "volatile_fields_removed": 5,
  "snapshot_size_bytes": 45000
}
```

## Success Criteria

- Stable, comparable snapshot
- All resources captured
