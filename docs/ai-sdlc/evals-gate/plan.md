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
| REQ-006 | `bash scripts/test-run-evals.sh`: a call that stalls once and then answers is green (the timeout is retried once, in a fresh copy); `EVAL_TIMEOUT_RETRIES=0` restores the strict behavior; a task that stalls on every try is still red; a wrong answer is run once, never retried |

## Review fix (2026-10-03)

Claude `stream-json` emits one `assistant` event per content block, blocks of
one message sharing `message.id`; a 2-message run counted 4 steps. Steps now
count distinct message ids. Proven by the self-test case "claude: steps count
messages, not content blocks" (`bash scripts/test-run-evals.sh`).

## Timeout retry (2026-10-07)

The gate is a required check, and a single stalled model call failed it. PR #197 (config-only) went red with `branch-rules` making zero steps in 300 s and `bugfix-first-skill` timing out too (exit 124): about 11 minutes. The same job re-run passed 5/5 in about 2 minutes, and the tasks normally take 6 to 16 seconds, so the stall was the provider's, not the configuration's.

REQ-006: a task that times out gets `EVAL_TIMEOUT_RETRIES` more tries (default 1), each in a fresh copy of the repo. The baseline is untouched, a wrong answer is never retried, and a task that stalls every time still fails, so a real regression is as visible as before.
