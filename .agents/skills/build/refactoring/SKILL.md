---
name: refactoring
description: "Safely modify existing code and manifests. Use when updating existing code, applying refactors, or modifying manifests without introducing regressions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Refactoring & Modification

> **Load trigger:** `"load refactoring skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Safely modify existing code and manifests.

## Responsibilities

- Update existing code
- Apply refactors
- Update manifests
- Maintain backward compatibility

## Inputs

- Existing code
- `tasks.json`

## Outputs

- Updated code

## Refactoring Rules

### Safety

- [ ] Existing tests pass before and after changes
- [ ] No breaking changes to public APIs without version bump
- [ ] No removal of functionality without deprecation period
- [ ] Backward compatibility maintained

### Quality

- [ ] Changes follow existing code patterns
- [ ] No new `any` types introduced
- [ ] No new lint warnings introduced
- [ ] Documentation updated for changed APIs

### Manifest Updates

- [ ] Resource limits maintained or improved
- [ ] SecurityContext maintained or improved
- [ ] Labels and annotations preserved
- [ ] Health checks preserved

### Verification

- [ ] `npm run lint` (or equivalent) passes
- [ ] `npm run typecheck` (or equivalent) passes
- [ ] Existing tests pass
- [ ] No regressions in behavior

## Tools

- Language-specific linters
- Type checkers
- Test runners
- Git diff for review

## Success Criteria

- No regressions introduced
- All existing tests pass
- Code quality maintained or improved
