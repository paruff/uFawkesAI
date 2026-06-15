---
name: ci-matrix-execution
description: "Run CI across multiple versions, platforms, or configurations. Use when defining matrix strategies or validating cross-version/platform compatibility."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Matrix Execution

> **Load trigger:** `"load ci-matrix-execution skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Run CI across multiple versions, platforms, or configurations.

## Responsibilities

- Define matrix (Node versions, OS, architectures)
- Validate matrix completeness
- Aggregate results across matrix combinations
- Detect version/platform-specific failures

## Inputs

- Matrix configuration
- Test configuration

## Outputs

- `matrix-report.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-matrix-execution/version-matrix` | Test across multiple runtime versions |
| `ci-matrix-execution/platform-matrix` | Test across multiple OS platforms |

## Matrix Definition

| Dimension | Values | Use When |
|-----------|--------|----------|
| Runtime version | 18, 20, 22 | Node.js compatibility |
| OS | ubuntu, macos, windows | Cross-platform support |
| Architecture | x64, arm64 | ARM support |
| Database | postgres, mysql | Multi-DB support |

## Matrix Rules

### Completeness

- [ ] All required combinations defined
- [ ] No unnecessary combinations (exclude known-incompatible)
- [ ] Include/exclude rules documented

### Failure Isolation

- [ ] Each matrix job runs independently
- [ ] Failure in one combination doesn't block others
- [ ] Matrix-specific failures flagged separately

### Result Aggregation

- [ ] All matrix results collected
- [ ] Per-combination pass/fail recorded
- [ ] Overall matrix status determined

## GitHub Actions Matrix Example

```yaml
jobs:
  test:
    strategy:
      matrix:
        node: [18, 20, 22]
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

## Success Criteria

- All matrix combinations tested
- Version/platform-specific failures detected
