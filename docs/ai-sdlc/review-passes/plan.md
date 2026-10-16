# Plan — Review passes

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

One PR: `REVIEW.md`, the review workflow, the check script and self-test, the
CI step that runs them, and the README map row.

## Verification Strategy

| REQ | Check |
|---|---|
| REQ-001, REQ-004 | `bash scripts/test-check-review-md.sh`: too long, missing section, missing file, and workflow not reading REVIEW.md each fail |
| REQ-002, REQ-003 | `actionlint`; the job runs on this PR (it needs `ANTHROPIC_API_KEY` as a repo secret, which is the owner's action) |
| REQ-005 | `bash scripts/check-readme-claims.sh` |
