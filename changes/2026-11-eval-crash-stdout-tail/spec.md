---
change: eval-crash-stdout-tail
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 242d0f1
---
# Evals: show the agent's stdout tail on a silent crash: spec

## Requirements

- R1. When the agent exits non-zero and its stderr is empty and its stdout is not, the runner prints `<id>: agent exited <rc>; stderr empty, stdout (last 1500 bytes):` followed by the last 1500 bytes of the stdout, each line prefixed with ` | `, to the runner's stderr.
- R2. When the agent exits non-zero and both stderr and stdout are empty, the runner prints `<id>: agent exited <rc>; no output on stderr or stdout`.
- R3. When stderr has content, behaviour is unchanged (R1 of the stderr change: the first 1500 bytes of stderr, nothing from stdout). Nothing is printed for an agent that exits 0, whatever it wrote.
- R4. Grading, retries, the report, the pass-rate gate and exit codes are unchanged. A timeout (exit 124) already writes a line to stderr, so it takes the stderr path.
- R5. `scripts/test-run-evals.sh` covers R1 to R3 with the stub agent.

## Design

Extend the one existing block after `out` is computed: when `rc` is non-zero, test whether the stderr file is empty; if so, print from `$raw` (the transcript the runner already holds) with `tail -c 1500`, else the existing `head -c 1500` of stderr. The stub agent needs no change: it already writes any `STUB_REPLY` to stdout and any `STUB_STDERR` to stderr.

## Verification

- R1, R2, R3, R5: `bash scripts/test-run-evals.sh`; the new R1 and R2 cases fail before the change.
- R4: the existing cases pass unchanged.
- End to end: the next crash in an Agent Config Evals run (none is expected on this PR).

## Areas of concern

Log content: stdout is the model's transcript and can include tool output from the task's throwaway copy. The block is bounded and CI masks repository secrets; a local run prints to the developer's own terminal.
