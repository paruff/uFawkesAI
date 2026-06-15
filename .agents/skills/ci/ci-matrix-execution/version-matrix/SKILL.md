---
name: version-matrix
description: "Test across multiple language/runtime versions. Use when validating compatibility across Node, Python, Go, or other runtime versions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Version Matrix Testing

> **Load trigger:** `"load version-matrix skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Test across multiple language/runtime versions.

## Responsibilities

- Run tests on each target version
- Validate compatibility
- Detect version-specific failures
- Report version coverage

## Inputs

- Matrix configuration (versions)
- Test configuration

## Outputs

- `version-matrix.json`

## Version Selection

| Language | LTS Versions | Current | Minimum |
|----------|-------------|---------|---------|
| Node.js | 18, 20 | 22 | 18 |
| Python | 3.10, 3.11, 3.12 | 3.13 | 3.10 |
| Go | 1.21, 1.22 | 1.23 | 1.21 |
| Rust | stable | stable | stable |

## Validation Rules

- [ ] All LTS versions tested
- [ ] Current version tested
- [ ] Minimum supported version tested
- [ ] No version-specific regressions

## Output Format

```json
{
  "versions_tested": ["18", "20", "22"],
  "results": {
    "18": "pass",
    "20": "pass",
    "22": "fail"
  },
  "failures": [
    {
      "version": "22",
      "error": "Syntax error in feature X"
    }
  ]
}
```

## Success Criteria

- All target versions tested
- Compatibility validated
