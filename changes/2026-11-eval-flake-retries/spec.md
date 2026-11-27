---
change: eval-flake-retries
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 89dc296
---
# Evals: retry flakes, never wrong answers: spec

## Requirements

- R1. When an agent exits non-zero, the parsed transcript has no text, and the task does not set `expect.ignore_agent_exit`, the task is retried (a crash).
- R2. When the exit code, outcome checks (`expect.*`) and tool-use rubric all pass but the step count is over `rubric.trajectory.max_steps`, the task is retried (a step overrun).
- R3. A task failing any other check is never retried: wrong or missing output, an `expect.file_absent` or `file_present` violation, a forbidden or missing tool, or a non-zero exit that produced output. The existing timeout retry (`EVAL_TIMEOUT_RETRIES`) is unchanged.
- R4. Retries are bounded by `EVAL_FLAKE_RETRIES` (default 1; 0 disables). Each retry runs in a fresh copy of the tree. The verdict is the last attempt's, so a task that fails every attempt fails.
- R5. Each retry prints `retry <id>: <crash|steps N > max M>, attempt <k> of <n>` to the runner's stderr. The report gains `attempts` per result, and the summary line says how many tasks needed a retry.
- R6. Baseline rates, exit codes and the gate's pass/fail rule are unchanged. The only task-file change is `rubric.trajectory.max_steps`: `branch-rules` 6 to 12, `commit-format` 4 to 8, `bugfix-first-skill` 8 to 12. `protected-env`, `route-implement` and `verifier-blocks-unproven` keep 6.
- R7. `scripts/test-run-evals.sh` covers R1 to R5.
- R8. Each of the three raised caps is at least the largest step count observed for that task over the eight reports gathered on 2026-11-27 (branch-rules 9, commit-format 7, bugfix-first-skill 8; and 11, 7 and 12 seen in discarded attempts), so the observed range passes.

## Design

Extract the per-task grading from the loop body into a function that sets the verdict, the three dimension results and the reasons. The attempt loop runs the agent, grades, and retries when the result is one of the two flake shapes (R1, R2) and attempts remain; the timeout retry stays where it is. The stub agent gains `STUB_FLAKE_ONCE=<marker>`: the first call exits 1 with no output (a crash), and `STUB_STEPS_FIRST` gives the first call a different step count. `attempts` is added to each report row.

## Verification

- R1, R2, R4, R5: new cases with the stub (crash then pass; overrun then pass; overrun every time still fails; `EVAL_FLAKE_RETRIES=0` fails the first overrun).
- R3: cases proving a wrong answer, a forbidden tool and a present `.env` are run once (the stub's call counter shows one call).
- R6, R7: all existing cases pass unchanged; `bash scripts/test-run-evals.sh`; `git diff` of the task files shows only the three `max_steps` values.
- R8: the observed counts are in the intent; `jq .rubric.trajectory.max_steps` on the three tasks.
- End to end: the Agent Config Evals run on the PR.

## Areas of concern

- A retried pass hides one bad attempt. A regression that makes a task flake at about 50% would pass about 75% of the time with one retry; one that fails consistently still fails. Retried tasks are printed and recorded so a rising count is visible.
- Step-count retry makes the trajectory cap a best-of-two measure; that is the intent, but the cap is no longer a hard per-run bound.
- The three caps are about doubled. The trajectory dimension still flags an agent that wanders far beyond a dozen steps, but it is less sensitive to a modest rise (for example 4 to 8 steps on `commit-format`). The caps were calibrated on eight reports from one model; a model change means re-measuring them.
- Refactoring the loop body into a function touches the heart of the gate; the 31 existing cases are the safety net.
