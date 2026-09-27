---
name: rules
description: "Reference rules for API design, GitOps, security, and testing conventions. Implements DORA AI Capabilities 1, 4, 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: rules

> **Load trigger:** "load rules skill" > **DORA:** AI Capabilities 1, 4, 7
> **Token cost:** Low

## Purpose

Reference rules for API design, GitOps, security, and testing conventions. These are the conventions that agents must follow when generating code, reviewing PRs, and validating configurations. Implements DORA AI Capabilities 1, 4, 7.

## When to Use

- Designing or changing any public-facing interface (api-design-rules)
- Creating branches, writing commits, or opening/reviewing PRs (gitops-rules)
- Touching auth, permissions, data handling, dependencies (security-rules)
- Writing, changing, or reviewing tests (testing-rules)

## Sub-skills (now integrated)

### Api Design Rules

- Use clear, stable names that reflect domain intent.
- Keep interfaces explicit; avoid ambiguous return types and hidden side effects.
- Handle errors consistently with actionable messages and typed/structured error paths.
- Preserve backward compatibility where possible; document breaking changes.
- Version public-facing APIs deliberately and document migration expectations.

### Gitops Rules

- Branch naming: `feat/*`, `fix/*`, `chore/*`, `docs/*`, `refactor/*`, `test/*`.
- Commit format: Conventional Commits (`type(scope): description`).
- PRs must include summary, verification evidence, risk notes, and rollback plan.
- Keep changes scoped and traceable to intent/spec/plan artifacts.
- Merge strategy: prefer squash merge unless repository policy requires otherwise.

### Security Rules

- Respect trust boundaries at all inputs, outputs, and external integrations.
- Never edit or commit protected files: `.env`, `*.pem`, `*.key`, `credentials.*`, `.git/` internals.
- Do not log secrets, tokens, or sensitive identifiers.
- Validate and sanitize untrusted input at boundaries.
- Require focused security review for auth, permissions, data handling, and dependency changes.

### Testing Rules

- Run the project's verification gates before every commit: typecheck, lint, tests, and build.
- Add or update tests for every behavioral change.
- Prefer deterministic unit tests first; add integration/e2e only when required by scope.
- Coverage expectation: new/changed logic must be covered by meaningful assertions.
- Never remove failing tests to make CI pass; fix root causes.

## Usage

```bash
# API design rules
load rules/api-design-rules skill

# GitOps rules
load rules/gitops-rules skill

# Security rules
load rules/security-rules skill

# Testing rules
load rules/testing-rules skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 1, 4, 7 references
- **AI stance audit** validates relevant clarity dimensions
