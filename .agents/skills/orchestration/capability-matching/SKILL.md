---
name: orchestration/capability-matching
description: Matches a free-form task description to the most capable agent using the capability registry. Use when the routing is not obvious from the task routing table alone.
license: MIT
compatibility: OpenCode, Claude Code, GitHub Copilot, Cursor
metadata:
  author: paruff
  suite: uFawkesAI
  dora_cap: "Cap 3 — Context Engineering"
---

# Capability Matching Skill

Route a task to the right agent by matching task keywords against declared agent capabilities from `.agents/registry/agent-capabilities.yaml`.

## When to Load

- The task does not clearly match a single row in the routing table
- Two agents could plausibly handle the task
- You need to justify _why_ a particular agent was chosen

## How It Works

1. Read `.agents/registry/agent-capabilities.yaml`
2. Extract keywords from the task description (nouns, verbs, domain terms)
3. Score each agent by keyword overlap with its `capabilities` and `description`
4. Return the top-ranked agent with a rationale

## Matching Algorithm

```
For each agent in registry:
    score = 0
    for each keyword in task_keywords:
        if keyword in agent.capabilities: score += 3
        if keyword in agent.description:  score += 2
        if keyword in agent.inputs:       score += 1
    if agent.consumes_from includes the agent that produced the input task: score += 2
Return highest-scoring agent
```

## Scoring Examples

| Task Keywords                    | Top Agent  | Rationale                        |
| -------------------------------- | ---------- | -------------------------------- |
| "generate kubernetes manifests"  | `build`    | manifest-generation capability   |
| "check for hardcoded secrets"    | `security` | secret-scanning capability       |
| "interpret deployment frequency" | `dora`     | metric-interpretation capability |
| "write test for login feature"   | `test`     | tdd-test-writing capability      |

## Output

A routing decision with:

- Selected agent name
- Match score
- Capabilities matched
- `consumes_from` check (whether required predecessors are done)
