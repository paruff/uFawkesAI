---
change: eval-flake-retries
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 1442384
---
# Evals: retry flakes, never wrong answers: plan

1. Test first: add `STUB_FLAKE_ONCE` and `STUB_STEPS_FIRST` to the stub and the cases for R1 to R5 in `scripts/test-run-evals.sh`; confirm the new cases fail (R7).
2. Extract the per-task grading in `scripts/run-evals.sh` into a function and add the flake retry around run and grade, with `EVAL_FLAKE_RETRIES` (R1 to R4).
3. Add the retry log line, `attempts` in the report rows and the summary count (R5).
4. Raise `max_steps` in `.agents/evals/tasks/branch-rules.json` (6 to 12), `commit-format.json` (4 to 8) and `bugfix-first-skill.json` (8 to 12) (R6, R8).
5. Run `bash scripts/test-run-evals.sh` (all cases) and the pre-commit hooks; confirm the existing 31 cases still pass (R6).
6. Push, open the PR and read the Agent Config Evals run (end to end).

## Verification

- R1 to R5, R7: the new cases pass; they failed in step 1.
- R3, R6: the existing cases pass unchanged; the call counter shows no retry for wrong-answer, forbidden-tool and file violations.
- R6, R8: the task-file diff is exactly the three `max_steps` values, each at or above the observed maximum listed in the intent.
