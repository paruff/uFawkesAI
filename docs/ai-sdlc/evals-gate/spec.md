# Specification — Evals gate merges

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 1

**REQ-001 — Rubric.** Every task declares `rubric.tool_use.forbidden` (and
optional `required`), anchored case-insensitive regexes over tool names, and
`rubric.trajectory.max_steps`. A task without them is a setup error (exit 2).

**REQ-002 — Transcript.** The runner parses OpenCode `--format json` and
Claude `stream-json` transcripts into answer text, tool names and step
count; plain text has no tools and 0 steps.

**REQ-003 — Scores and gate.** Each task gets pass/fail on task success, tool
use and trajectory. `baseline.json` holds a rate per dimension; the run fails
if any rate is below its baseline. The report records per-task scores.

**REQ-004 — Bounded.** A task exceeding `EVAL_TASK_TIMEOUT` (default 300 s)
fails instead of hanging the job.

**REQ-005 — Triggers.** `agent-config-ci.yml` runs on every PR (the model
only when a config path changed: `AGENTS.md`, `.agents/`, `.claude/`,
`.opencode/`, `opencode.json`, `scripts/hooks/`, `.pre-commit-config.yaml`,
the runner), on pushes to `main` touching those paths, and weekly.
