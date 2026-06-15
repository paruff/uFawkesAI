---
name: docker-cache
description: "Speed up Docker builds by caching layers. Use when configuring buildx cache or measuring Docker build speed improvements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Docker Layer Caching

> **Load trigger:** `"load docker-cache skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Speed up Docker builds by caching layers.

## Responsibilities

- Configure buildx cache backend
- Validate cache usage in builds
- Measure build speed improvements
- Optimize Dockerfile layer ordering

## Inputs

- `Dockerfile`
- Build configuration

## Outputs

- `docker-cache.json`

## Optimization Rules

### Layer Ordering

- [ ] Least-changing layers first (COPY .gitignore, then COPY src)
- [ ] Package install before source copy
- [ ] Multi-stage builds for smaller images
- [ ] `.dockerignore` excludes unnecessary files

### Cache Configuration

- [ ] Buildx cache backend configured
- [ ] Cache scope defined per branch/tag
- [ ] Cache eviction policy set

## Buildx Example

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: myapp:latest
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Validation Rules

- [ ] Cache hit rate > 50%
- [ ] Build time reduced vs cold build
- [ ] No stale layers used

## Success Criteria

- Significant build speed improvement
- Cache properly invalidated on changes
