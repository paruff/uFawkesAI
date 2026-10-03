# Plan — Evals gate merges

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

One PR: runner (rubric, transcript parsing, per-dimension gate, timeout),
self-test cases, rubrics on the five tasks, a baseline set from real runs,
workflow triggers, and the continuous-evals skill. Then the owner adds the
job to branch protection.

## Verification Strategy

| REQ | Check |
|---|---|
| REQ-001..004 | `bash scripts/test-run-evals.sh`: no-rubric and old-baseline setup errors; OpenCode and Claude transcripts; forbidden, missing-required and MCP tools; too many steps; per-dimension rates; a stalled agent times out red |
| REQ-003 | Real run (`EVAL_HARNESS=opencode`, `google/gemini-3.1-flash-lite`, OpenCode 1.18.32): 5/5 on all three dimensions, twice, recorded in `baseline.json` |
| REQ-005 | `actionlint`; the job runs on this PR; a test PR that breaks a rule file goes red (AC-AI-07) |
| AC-AI-07 | Owner: `gh api repos/paruff/uFawkesAI/branches/main/protection` lists `🧪 Agent config evals` |
