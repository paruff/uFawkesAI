---
change: run-evals-model-default
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-26
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Align eval model references

## Problem

`gemini-3.1-flash-lite` no longer resolves in `opencode run` (`ProviderModelNotFoundError`), which broke the Agent Config Evals until #387 moved the workflow to `google/gemini-3.5-flash-lite`. Two references to the old id remain: the `run-evals.sh` default (used by local runs and its header comment) and the `model` field in `.agents/evals/baseline.json`. A local `bash scripts/run-evals.sh` with no `EVAL_MODEL` fails the same way, and the baseline names a model that is no longer used.

## Proposed outcome

The `run-evals.sh` default, its header comment and `baseline.json` all name `google/gemini-3.5-flash-lite`, the model the workflow runs and the evals pass on (6/6 on every dimension).

## Affected users and systems

Maintainers running evals locally; `scripts/run-evals.sh`, `.agents/evals/baseline.json`.

## Constraints

Pass-rate thresholds stay at 1.0 (never lowered). No change to grading, harness or workflow.

## How we know it worked

`bash scripts/test-run-evals.sh` still passes, and no `gemini-3.1-flash-lite` reference is left outside history (`CHANGELOG.md`, earlier `changes/`).

## Out of scope

Changing the model again; the `gemini-3.1-pro-preview` entries in `opencode/`; making the workflow and script defaults share one source.

## Open questions

None.
