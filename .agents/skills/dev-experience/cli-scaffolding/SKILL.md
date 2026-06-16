---
name: cli-scaffolding
description: "Provide CLI commands that scaffold new components, pipelines, tests, and GitOps structures. Use when scaffolding new services, pipeline-spec.yaml, GitOps overlays, or test suites."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CLI Scaffolding & Developer Tooling

> **Load trigger:** `"load cli-scaffolding skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Provide CLI commands that scaffold new components, pipelines, tests, and GitOps structures.

## Responsibilities

- Scaffold new Fawkes services
- Scaffold `pipeline-spec.yaml`
- Scaffold GitOps overlays
- Scaffold test suites
- Validate CLI UX

## Inputs

- Fawkes CLI
- Templates

## Outputs

- `scaffold-report.json`

## Sub-Skills

| Skill                                  | Purpose                            |
| -------------------------------------- | ---------------------------------- |
| `cli-scaffolding/template-scaffolding` | Generate components from templates |
| `cli-scaffolding/cli-ux`               | Validate CLI user experience       |

## Scaffold Commands

| Command                          | Output                       |
| -------------------------------- | ---------------------------- |
| `fawkes scaffold service <name>` | New service with boilerplate |
| `fawkes scaffold pipeline`       | `pipeline-spec.yaml`         |
| `fawkes scaffold gitops <env>`   | GitOps overlay structure     |
| `fawkes scaffold test <type>`    | Test file with patterns      |

## Rules

- [ ] Scaffolding completes in < 10 seconds
- [ ] Generated code follows conventions
- [ ] Tests included by default
- [ ] GitOps structure correct

## Output Format

```json
{
  "skill": "cli-scaffolding",
  "command": "fawkes scaffold service my-service",
  "status": "success",
  "files_created": [
    "src/my-service/index.ts",
    "src/my-service/handler.ts",
    "tests/my-service/handler.test.ts",
    "manifests/my-service/deployment.yaml"
  ],
  "duration_seconds": 3
}
```

## Success Criteria

- Developer can scaffold a new service in < 10 seconds
- All files follow conventions
- Tests included
