---
name: dependency-cache
description: "Cache and restore language dependencies. Use when caching Node modules, Python wheels, or validating lockfile consistency."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dependency Cache Management

> **Load trigger:** `"load dependency-cache skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Cache and restore language dependencies.

## Responsibilities

- Cache Node modules (`node_modules`)
- Cache Python wheels (`~/.cache/pip`)
- Validate lockfile consistency
- Detect dependency changes

## Inputs

- `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`
- `requirements.txt` / `poetry.lock` / `Pipfile.lock`
- `go.sum`

## Outputs

- `dependency-cache.json`

## Cache Keys

| Lock File | Cache Path | Restore Key |
|-----------|-----------|-------------|
| `package-lock.json` | `node_modules` | `node_modules-{hash}` |
| `yarn.lock` | `node_modules` | `node_modules-{hash}` |
| `requirements.txt` | `~/.cache/pip` | `pip-{hash}` |
| `go.sum` | `~/go/pkg/mod` | `go-mod-{hash}` |

## Validation Rules

- [ ] Cache key matches lockfile hash
- [ ] Cache restored successfully
- [ ] No stale dependencies in cache
- [ ] Lockfile consistency maintained

## GitHub Actions Example

```yaml
- name: Cache node modules
  uses: actions/cache@v4
  with:
    path: node_modules
    key: node_modules-${{ hashFiles('package-lock.json') }}
    restore-keys: |
      node_modules-
```

## Success Criteria

- Cache restored successfully
- No dependency mismatches after restore
