---
name: skill-lifecycle
description: "Manage skill lifecycle: deprecation, versioning, status transitions, and dependency validation. Use when deprecating a skill, updating a skill version, checking lifecycle status, or validating the dependency graph."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill Lifecycle Management

> **Load trigger:** `"load skill-lifecycle skill"` > **DORA:** Cap 3 (Context Engineering)
> **Token cost:** Low

Manage the lifecycle of uFawkesAI skills — deprecation, version bumps, status transitions, and dependency graph validation.

## Source of Truth

The canonical registry is at `.agents/registry/skill-lifecycle.yaml`. This is a machine-readable YAML file that all agents should reference before loading a skill.

Schema: `.agents/schema/skill-lifecycle.json`

## Lifecycle Statuses

| Status         | Meaning                               | When to Use                    |
| -------------- | ------------------------------------- | ------------------------------ |
| `active`       | In current use, maintained            | Default for all new skills     |
| `stable`       | Mature, tested, safe                  | After 3+ months of active use  |
| `beta`         | Functional but may change             | New skills still being refined |
| `draft`        | Incomplete, not ready for use         | Scaffolding or planned skills  |
| `deprecated`   | Replaced, do NOT load in new sessions | When a replacement exists      |
| `experimental` | Proof of concept, may be deleted      | One-off experiments            |

## Deprecation Workflow

To deprecate a skill:

1. Set `status: deprecated` in `.agents/registry/skill-lifecycle.yaml`
2. Add `replaced_by` pointing to the replacement skill path
3. Add `deprecation_reason` explaining why
4. Remove the skill from any agent's skill-loading recommendations
5. Add a deprecation notice at the top of the skill's SKILL.md
6. Update `.agents/README.md` skill table (strikethrough or (deprecated) label)

## Versioning Convention

- **Major** (1.x.x): Breaking changes — skill interface or output format changed
- **Minor** (x.1.x): New capabilities added, backward compatible
- **Patch** (x.x.1): Bug fixes, documentation updates, no behavior change

## Dependency Graph

The dependency graph is generated from `.agents/registry/skill-lifecycle.yaml` by `scripts/agent-skill-graph.sh`. Outputs:

| File                                                                               | Purpose                                             |
| ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| `.agents/skills/platform-engineering/skill-dependency-graph/skill-graph.json`      | Full graph with nodes, edges, and topological order |
| `.agents/skills/platform-engineering/skill-dependency-graph/graph-validation.json` | Validation report including cycle detection         |

Regenerate after any lifecycle registry change:

```bash
bash scripts/agent-skill-graph.sh
```

## Checking a Skill's Lifecycle Status

Before loading a skill, check:

1. Read `.agents/registry/skill-lifecycle.yaml`
2. Find the skill path
3. If `status` is `deprecated`, use `replaced_by` instead
4. If `dependencies` is non-empty, ensure those skills are also available
5. Check the dependency graph for any ordering constraints

## When to Load

- Before creating a new skill (check if one already exists)
- Before deprecating a skill (check what depends on it)
- When a skill's output seems wrong (check if it's deprecated or replaced)
- After adding a new skill (run the graph validator)
- When an agent reports a skill loading error (check the registry)
