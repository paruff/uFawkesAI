---
name: platform-matrix
description: "Test across Linux, macOS, and Windows. Use when validating cross-platform behavior for CLI tools, libraries, or cross-platform applications."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Platform Matrix Testing

> **Load trigger:** `"load platform-matrix skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Test across Linux, macOS, and Windows.

## Responsibilities

- Run tests on each target OS
- Validate cross-platform behavior
- Detect platform-specific failures
- Report platform coverage

## Inputs

- Matrix configuration (platforms)
- Test configuration

## Outputs

- `platform-matrix.json`

## Platform Selection

| Platform | Runner | Use When |
|----------|--------|----------|
| Linux | `ubuntu-latest` | Primary platform |
| macOS | `macos-latest` | macOS support needed |
| Windows | `windows-latest` | Windows support needed |

## Validation Rules

- [ ] All target platforms tested
- [ ] Platform-specific code paths validated
- [ ] File system operations work cross-platform
- [ ] Path separators handled correctly
- [ ] Line endings handled correctly

## Output Format

```json
{
  "platforms_tested": ["ubuntu-latest", "macos-latest", "windows-latest"],
  "results": {
    "ubuntu-latest": "pass",
    "macos-latest": "pass",
    "windows-latest": "fail"
  },
  "failures": [
    {
      "platform": "windows-latest",
      "error": "Path separator issue in src/utils.ts:42"
    }
  ]
}
```

## Success Criteria

- All target platforms pass
- Cross-platform behavior validated
