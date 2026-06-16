---
name: template-application
description: "Apply golden-path templates to new or existing components. Use when creating new services, pipelines, or GitOps configurations from templates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Template Application

> **Load trigger:** `"load template-application skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Apply golden-path templates to new or existing components.

## Responsibilities

- Apply service templates
- Apply pipeline templates
- Apply GitOps templates
- Validate template compliance

## Inputs

- `tasks.json`
- Template rules
- Golden-path templates

## Outputs

- Templated files

## Available Templates

### Service Template

```
src/
├── index.ts              # Entry point
├── config.ts             # Configuration
├── routes/               # API routes
├── services/             # Business logic
├── models/               # Data models
├── middleware/            # Express/Fastify middleware
└── tests/                # Test files
```

### Pipeline Template

```yaml
# Standard pipeline with all required stages
stages:
  - lint
  - test
  - security-scan
  - build
  - sign
  - sbom
  - deploy
```

### GitOps Template

```
overlays/
├── dev/                  # Development environment
├── staging/              # Staging environment
└── production/           # Production environment
```

## Application Rules

### Consistency

- [ ] Template structure followed exactly
- [ ] File naming conventions matched
- [ ] Import patterns matched
- [ ] Error handling patterns matched

### Customization

- [ ] Service-specific values filled in
- [ ] Environment-specific overrides applied
- [ ] Non-required sections removed if not applicable

### Compliance

- [ ] Template includes all required security gates
- [ ] Template includes health checks
- [ ] Template includes resource limits
- [ ] Template includes proper labeling

## Success Criteria

- Templates applied consistently
- No template violations
- Customizations are minimal and documented
