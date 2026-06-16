---
name: cli-ux
description: "Ensure the Fawkes CLI provides a clean, intuitive developer experience. Use when validating command naming, help text, error messages, or interactive prompts."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CLI UX Validation

> **Load trigger:** `"load cli-ux skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Ensure the Fawkes CLI provides a clean, intuitive developer experience.

## Responsibilities

- Validate command naming
- Validate help text
- Validate error messages
- Validate interactive prompts

## Inputs

- Fawkes CLI

## Outputs

- `cli-ux.json`

## UX Rules

### Command Naming

| Rule       | Example                              |
| ---------- | ------------------------------------ |
| Verb-first | `fawkes scaffold`, `fawkes validate` |
| Kebab-case | `fawkes scaffold service`            |
| Consistent | `fawkes <verb> <noun>`               |

### Help Text

- [ ] Every command has `--help`
- [ ] Examples included
- [ ] Required args documented
- [ ] Optional flags documented

### Error Messages

- [ ] Actionable (tells user what to do)
- [ ] Includes error context
- [ ] No stack traces for user errors
- [ ] Color-coded (red for errors, yellow for warnings)

### Interactive Prompts

- [ ] Defaults provided
- [ ] Confirmation for destructive actions
- [ ] Cancel option available
- [ ] Progress indicators for long operations

## Output Format

```json
{
  "skill": "cli-ux",
  "status": "pass | fail",
  "checks": {
    "command_naming": "pass",
    "help_text": "pass",
    "error_messages": "pass",
    "interactive_prompts": "pass"
  },
  "issues": []
}
```

## Success Criteria

- Clear, intuitive CLI UX
- All commands documented
- Errors are actionable
