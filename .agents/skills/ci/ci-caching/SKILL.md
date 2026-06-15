---
name: ci-caching
description: "Reduce CI execution time by caching dependencies, build layers, and test artifacts. Use when optimizing CI cache strategy or validating cache hit rates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Caching

> **Load trigger:** `"load ci-caching skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Reduce CI execution time by caching dependencies, build layers, and test artifacts.

## Responsibilities

- Cache Node/Python dependencies
- Cache Docker layers
- Cache test results
- Validate cache hit/miss rates

## Inputs

- CI workspace
- Cache configuration

## Outputs

- `cache-report.json`
- `cache-stats.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-caching/dependency-cache` | Cache and restore language dependencies |
| `ci-caching/docker-cache` | Speed up Docker builds with layer caching |

## Caching Strategy

| Artifact | Cache Key | TTL |
|----------|-----------|-----|
| Node modules | `package-lock.json` hash | 7 days |
| Python wheels | `requirements.txt` hash | 7 days |
| Docker layers | `Dockerfile` hash | 3 days |
| Test results | `test-files` hash | 1 day |

## Tools

- GitHub Actions `actions/cache`
- Docker buildx cache
- Custom cache scripts

## Success Criteria

- High cache hit rate (> 80%)
- Reduced CI runtime
- Cache invalidation on dependency changes
