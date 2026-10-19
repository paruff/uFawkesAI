# Spec — Review passes

**Traces to:** [`intent.md`](intent.md)

- **REQ-001** `REVIEW.md` exists at the repo root, is 60 lines or fewer, and
  has the sections `Flag`, `Skip`, `Severity` and `Output`.
- **REQ-002** `.github/workflows/agent-review.yml` runs on `pull_request`,
  has `contents: read` and `pull-requests: write` only, reads `REVIEW.md`, and
  cannot approve or merge.
- **REQ-003** The job fails with an explicit message when
  `ANTHROPIC_API_KEY` is unset, and skips fork PRs (no secrets there) by
  saying so.
- **REQ-004** `scripts/check-review-md.sh` enforces REQ-001 and REQ-002's
  wiring; its self-test proves each failure mode goes red.
- **REQ-005** The README playbook map lists the review pass with files that
  exist (`scripts/check-readme-claims.sh` passes).

## Acceptance

`bash scripts/test-check-review-md.sh`, `bash scripts/check-review-md.sh`,
`bash scripts/check-readme-claims.sh`, `actionlint`.
