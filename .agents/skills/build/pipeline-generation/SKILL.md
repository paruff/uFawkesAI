---
name: pipeline-generation
description: "Generate or update pipeline-spec.yaml. Use when creating or modifying CI/CD pipelines with required stages and security gates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Generation

> **Load trigger:** `"load pipeline-generation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate or update `pipeline-spec.yaml`.

## Responsibilities

- Add required stages (lint, test, build, deploy)
- Add security gates (SAST, SCA, signing, SBOM)
- Add test stages (unit, integration, e2e)
- Add signing and SBOM stages

## Inputs

- `tasks.json`
- Governance rules
- Existing pipeline configuration

## Outputs

- `pipeline-spec.yaml`

## Generation Rules

### Required Stages

- [ ] Lint/format stage
- [ ] Unit test stage
- [ ] Build stage
- [ ] SAST scan stage
- [ ] SCA/dependency scan stage
- [ ] Container build stage (if applicable)
- [ ] Image signing stage (if applicable)
- [ ] SBOM generation stage (if applicable)
- [ ] Deployment stage (with approval gate)

### Pipeline Hardening

- [ ] Actions pinned to commit SHAs
- [ ] Secrets accessed only via `${{ secrets.NAME }}`
- [ ] No secrets echoed or logged
- [ ] Least privilege permissions for jobs
- [ ] Branch protection enforced

### Gating

- [ ] Security scans required for merge
- [ ] Build fails on critical/high findings
- [ ] Manual approval for production deployments
- [ ] Rollback mechanism defined

## Output Format

```yaml
name: Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: Lint
        run: make lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: Test
        run: make test

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: SAST
        run: make sast
      - name: SCA
        run: make sca

  build:
    needs: [lint, test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: Build
        run: make build
      - name: Sign
        run: make sign
      - name: SBOM
        run: make sbom
```

## Success Criteria

- Pipeline includes all required security gates
- Pipeline passes policy validation
- Deployment requires approval
