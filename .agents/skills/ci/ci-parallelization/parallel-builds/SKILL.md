---
name: parallel-builds
description: "Build multiple components or images in parallel. Use when identifying independent build targets or running concurrent builds."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Parallel Build Execution

> **Load trigger:** `"load parallel-builds skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Build multiple components or images in parallel.

## Responsibilities

- Identify independent build targets
- Run builds concurrently
- Validate artifact integrity
- Aggregate build results

## Inputs

- Build targets (from `component-map.json`)
- Build configuration

## Outputs

- `parallel-build-report.json`

## Parallelization Rules

### Independence Detection

- [ ] Build targets with no shared dependencies can build in parallel
- [ ] Service A and Service B can build concurrently if independent
- [ ] Library builds should precede service builds that depend on them
- [ ] Docker images with different base layers can build in parallel

### Concurrency Safety

- [ ] Build artifacts written to separate directories
- [ ] No shared build caches without locking
- [ ] Build logs captured per job
- [ ] Build failures isolated per job

### Validation

- [ ] All artifacts produced
- [ ] Artifact checksums verified
- [ ] No cross-contamination between builds

## GitHub Actions Example

```yaml
jobs:
  build-service-a:
    runs-on: ubuntu-latest
    steps:
      - run: make build SERVICE=service-a
  build-service-b:
    runs-on: ubuntu-latest
    steps:
      - run: make build SERVICE=service-b
```

## Success Criteria

- Reduced total build time
- All artifacts produced correctly
- No build conflicts
