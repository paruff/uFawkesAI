---
change: run-evals-model-default
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 1a33360
---
# Align eval model references: spec

## Requirements

- R1. The `opencode` default in `scripts/run-evals.sh` (and its header comment) is `google/gemini-3.5-flash-lite`.
- R2. `.agents/evals/baseline.json` has `"model": "google/gemini-3.5-flash-lite"`, `"tasks": 6` (the current task count) and a note recording that it was re-measured on that model. The three rates stay at 1.0.
- R3. `scripts/test-run-evals.sh` passes unchanged; grading and exit codes are unchanged.

## Design

Two string replacements and the baseline metadata. The baseline `model` and `tasks` fields are informational (only the rates are gated), so no behavior changes.

## Verification

- R1, R2: `git grep gemini-3.1-flash-lite` finds nothing outside `CHANGELOG.md` and earlier changes.
- R3: `bash scripts/test-run-evals.sh`.
- End to end: Agent Config Evals on this PR (it touches `scripts/run-evals.sh`, so the model runs) must pass at the 1.0 baseline.

## Areas of concern

The baseline note must stay truthful: it cites the real runs on the new model (the passing runs on #387 and #388, 2026-11-25/26), not the old October ones.
