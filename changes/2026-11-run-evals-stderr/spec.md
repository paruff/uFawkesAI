---
change: run-evals-stderr
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-26
approved_sha: dc22ec4
---
# Print the agent's stderr when an eval task fails: spec

## Requirements

- R1. When the agent for a task exits non-zero, `run-evals.sh` prints `<id>: agent exited <rc>; stderr (first 1500 bytes):` and then up to 1500 bytes of the agent's stderr, each line prefixed with ` | `, to the runner's stderr.
- R2. Nothing is printed for a task whose agent exits 0, even if it wrote to stderr.
- R3. Grading, the report, the pass-rate gate and the exit codes are unchanged. `ignore_agent_exit` tasks still print the stderr when the agent exits non-zero (they are only exempt from failing on it).
- R4. `scripts/test-run-evals.sh` covers R1 and R2 with the stub agent.

## Design

One block after `out` is computed in the per-task loop, before the verdict. `head -c 1500` bounds it; the stub agent gains `STUB_STDERR` so the test can drive it. The timeout path already appends a message to the same stderr file, so a stall is explained too.

## Verification

- R1, R2, R4: `bash scripts/test-run-evals.sh` (31 cases, the 4 new ones included). The R1 case failed before the change and passes after.
- R3: the other 27 existing cases pass unchanged.
- End to end: the next Agent Config Evals run on a PR that touches agent config.

## Areas of concern

Log content: agent stderr can contain provider error text. GitHub masks repository secrets in logs; a local run prints to the developer's own terminal.
