---
name: code-quality
description: "Validate code quality, formatting, and maintainability. Use when running linters, formatters, and checking naming conventions and directory structure."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Code Quality Validation

> **Load trigger:** `"load code-quality skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate code quality, formatting, and maintainability.

## Responsibilities

- Run linters
- Run formatters (check mode, not fix)
- Validate naming conventions
- Validate directory structure
- Validate test coverage

## Inputs

- Build output (source code)

## Outputs

- `code-quality.json`

## Validation Rules

### Linting

- [ ] Lint passes with no errors
- [ ] Lint warnings documented (if any)
- [ ] No new lint warnings introduced

### Formatting

- [ ] Code formatted per project conventions
- [ ] No formatting diffs in review
- [ ] Consistent indentation and style

### Naming Conventions

- [ ] Variables/functions use project convention (camelCase, snake_case)
- [ ] Classes/Types use PascalCase
- [ ] Constants use UPPER_SNAKE_CASE or project convention
- [ ] File names follow project convention

### Directory Structure

- [ ] Files in correct directories per architecture
- [ ] Test files co-located or in test directory per convention
- [ ] No files in wrong layer

### Type Safety

- [ ] No `any` types (or justified with comment)
- [ ] No `@ts-ignore` or `@ts-expect-error` without justification
- [ ] No `type: ignore` (Python) without justification
- [ ] Proper type exports

### Code Smells

- [ ] No dead code left in place
- [ ] No commented-out code blocks
- [ ] No TODO without issue number
- [ ] No magic numbers or strings

## Tools

| Language   | Linter        | Formatter |
| ---------- | ------------- | --------- |
| TypeScript | ESLint        | Prettier  |
| Python     | Ruff / Flake8 | Black     |
| Go         | golangci-lint | gofmt     |
| Rust       | clippy        | rustfmt   |

## Output Format

```json
{
  "skill": "code-quality",
  "status": "pass | fail",
  "lint": {
    "status": "pass | fail",
    "errors": 0,
    "warnings": 2,
    "details": ["Unused import at src/utils.ts:5"]
  },
  "formatting": {
    "status": "pass | fail",
    "diffs": 0
  },
  "naming": {
    "status": "pass | fail",
    "violations": []
  },
  "type_safety": {
    "status": "pass | fail",
    "any_count": 0,
    "ts_ignore_count": 0
  }
}
```

## Success Criteria

- Code meets quality standards
- No new lint errors or warnings
- Formatting consistent
