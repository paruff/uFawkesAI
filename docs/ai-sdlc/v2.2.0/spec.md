# Spec — v2.2.0

**Traces to:** [`intent.md`](intent.md)

- **REQ-001** The image pins Superpowers 7.0.1, OpenCode 2.1.2 and Claude Code 2.1.308; `verify-tools.sh ai` passes.
- **REQ-002** OpenCode 2.x is pinned from `opencode.ai/files/bin/<v>/` by sha256 (amd64 baseline, arm64) in `tools.lock.json`.
- **REQ-003** The repo's OpenCode config validates (`opencode/validate.sh`) and loads in the 2.x binary inside the image.
- **REQ-004** `/review-local` exists for Claude Code and OpenCode, reads `REVIEW.md`, is read-only, and `/ship` runs it before commit; a HIGH finding blocks the ship.
- **REQ-005** Lifecycle documented: plan (`intent.md`, `spec.md`, `plan.md`) → build → verify → `/review-local` → ship → CI agent review → human merge.
- **REQ-006** `opencode/sync.sh` and its host `--apply` mode are removed. `opencode/bake.sh` runs only inside the image build and refuses otherwise.
- **REQ-007** `agent-review.yml` warns, and does not fail, when `ANTHROPIC_API_KEY` is unset.
- **REQ-008** The ai base publishes as `fawkes-space:base-<version>`; there is no `fawkes-space-ai` package.

## Acceptance

`images/devsecops/tests/verify-tools.sh ai` and `scripts/multi-harness-smoke.sh` in a built image;
`bash opencode/validate.sh`; `bash scripts/check-review-md.sh`; a green `v2.2.0-rc.1` run.
