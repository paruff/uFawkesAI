# Plan — Placeholder audit

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

One PR: add `scripts/check-placeholders.sh` + self-test (in
`scripts/run-unit-tests.sh`), call it from preflight and verify, delete
`.template` in setup, add the `.template` marker and Step 0.

## Verification Strategy

| REQ | Check |
|---|---|
| REQ-001, REQ-002 | `bash scripts/test-check-placeholders.sh` (clean passes; marker fails without `.template`; template mode passes; `PLACEHOLDER_ENFORCE=1` fails; reports `file:line`; skips scripts and backticked mentions) |
| REQ-003 | `bash scripts/preflight.sh` passes here (template mode); `PREFLIGHT_ENFORCE_PLACEHOLDERS=1 bash scripts/preflight.sh` fails listing the markers |
| REQ-004 | `bash scripts/setup.sh --dry-run` prints the `.template` deletion |
