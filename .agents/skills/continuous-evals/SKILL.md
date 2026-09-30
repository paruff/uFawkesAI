---
name: continuous-evals
description: "Regression-gate changes to the agent configuration (AGENTS.md, .agents/ rules, skills, agents, workflows, hooks) by replaying recorded tasks and blocking if the pass rate drops below baseline. Use when changing any agent configuration, or when adding an eval task after a real agent mistake. Implements DORA AI Capability 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: continuous-evals

> **Load trigger:** "load continuous-evals skill" > **DORA:** AI Capability 7: Quality internal platforms
> **Token cost:** Low to load; a run costs one cheap-model call per task

## Purpose

Agent configuration is code: a reworded rule or a retired skill can silently
change what agents do. This skill makes configuration changes regression-safe
the same way tests make code changes safe.

## How it works

| Piece | Path |
| --- | --- |
| Tasks (one JSON file each) | `.agents/evals/tasks/*.json` |
| Baseline pass rate | `.agents/evals/baseline.json` |
| Runner | `scripts/run-evals.sh` |
| Gate's own self-test (offline, stub agent) | `scripts/test-run-evals.sh` |
| CI gate | `.github/workflows/agent-config-ci.yml` |

Each task runs in a throwaway copy of the working tree with `claude -p`
(default model: Haiku), and is graded deterministically — `output_regex`,
`file_absent`, `file_present`. The run fails if the pass rate is below
`baseline.json`, if there are no tasks, or if a task has no expectation.

## Procedure

1. Changing configuration? Run `scripts/run-evals.sh` before pushing.
   CI runs it anyway on any change to `AGENTS.md` or `.agents/`.
2. An agent got something wrong in real work? Add a task that reproduces it:

   ```json
   {
     "id": "short-kebab-id",
     "why": "which rule/skill/agent this protects",
     "prompt": "the real request, answerable in a few turns",
     "permission_mode": "acceptEdits",
     "expect": { "output_regex": "…" }
   }
   ```

   Prefer a grader that cannot pass by accident: a file check, or a regex
   that only the correct answer matches.
3. Raising the baseline: allowed any time the suite passes at the higher rate.
   Lowering it needs a reason in the PR description — that is the point.

## Limits

- A regex grader checks the answer, not the reasoning. Keep tasks narrow.
- Model output varies; tasks must be robust to phrasing, or they flake and
  someone lowers the baseline to get green.
