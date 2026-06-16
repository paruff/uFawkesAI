---
name: code-generation
description: "Generate code that satisfies the specification, design, and plan. Use when writing new source code following templates and conventions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Code Generation

> **Load trigger:** `"load code-generation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate code that satisfies the specification, design, and plan.

## Responsibilities

- Generate new source code
- Follow project templates and conventions
- Implement required interfaces
- Ensure code is testable

## Inputs

- `tasks.json`
- `design.md`
- Existing codebase conventions

## Outputs

- Source code files

## Generation Rules

### Code Quality

- [ ] Code compiles without errors
- [ ] Code follows project style guide
- [ ] No `any` types in TypeScript (use proper types)
- [ ] No commented-out code left in place
- [ ] No TODO comments without associated issue numbers

### Conventions

- [ ] Naming follows project conventions (camelCase, snake_case, etc.)
- [ ] File structure matches existing patterns
- [ ] Import order matches project convention
- [ ] Error handling follows project patterns

### Testability

- [ ] Functions are pure where possible
- [ ] Dependencies are injectable (not hardcoded)
- [ ] I/O is abstracted behind interfaces
- [ ] Complex logic is broken into testable units

### Security

- [ ] No hardcoded secrets or credentials
- [ ] Input validation applied at boundaries
- [ ] Output encoding applied for context
- [ ] Sensitive data not logged

## Tools

- Language-specific linters (ESLint, Ruff, golangci-lint)
- Type checkers (tsc, mypy, go vet)
- Formatters (Prettier, Black, gofmt)

## Success Criteria

- Code compiles and follows conventions
- Code implements all required acceptance criteria
- Code is testable and secure
