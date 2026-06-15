---
name: unit-mocking-isolation
description: "Isolate OBS and PIPE logic from external systems to ensure deterministic, fast tests. Use when mocking Git operations, registry interactions, filesystem operations, Kubernetes API calls, or network requests."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Unit Mocking & Isolation

> **Load trigger:** `"load unit-mocking-isolation skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Isolate OBS and PIPE logic from external systems to ensure deterministic, fast tests.

## Responsibilities

- Mock Git operations
- Mock registry interactions
- Mock filesystem operations
- Mock Kubernetes API calls
- Mock network requests

## Inputs

- Mock definitions
- Unit test files

## Outputs

- `mock-report.json`

## Mock Targets

| Target | Tool | Use When |
|--------|------|----------|
| Git operations | `ts-mockito` | Testing commit, push, pull |
| Registry | `nock` | Testing image pull, push |
| Filesystem | `jest.mock('fs')` | Testing file read/write |
| K8s API | `nock` | Testing pod, deployment operations |
| HTTP | `nock` | Testing API calls |

## Mock Validation Rules

- [ ] Zero real network calls
- [ ] Zero real filesystem writes
- [ ] All mocks validated
- [ ] Mock cleanup after each test
- [ ] No mock leaks between tests

## Mock Example

```typescript
// Mock Git operations
const mockGit = mock<GitClient>();
when(mockGit.commit(anything())).thenResolve({ sha: 'abc123' });

// Mock registry
nock('https://registry.example.com')
  .get('/v2/my-app/manifests/latest')
  .reply(200, manifest);
```

## Output Format

```json
{
  "skill": "unit-mocking-isolation",
  "status": "pass | fail",
  "mocks_used": 8,
  "real_network_calls": 0,
  "real_fs_writes": 0,
  "mock_validations": "all_pass"
}
```

## Success Criteria

- Zero real network calls
- Zero real filesystem writes
- All mocks validated
