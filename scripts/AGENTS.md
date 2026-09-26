# Rules for `scripts/`

This file is the dual-harness "nested rule" example: OpenCode's Rules
feature and Claude Code's memory system both load an `AGENTS.md`/
`CLAUDE.md` from the directory you're working in, in addition to the
repo root. It only applies while you're working under `scripts/` — it is
not loaded when working elsewhere in the repo.

## Conventions for scripts in this directory

- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Scripts must be idempotent — safe to run more than once without side
  effects piling up (see `setup.sh`'s own header comment for the pattern).
- A script that changes repository state (creates files, installs hooks)
  prints a short success summary at the end; a script that only reports
  (e.g. `weekly-metrics.sh`, `token-audit.sh`) does not need to.
- Prefer POSIX-portable constructs; this repo's devcontainer and CI both
  run on Linux, but contributors may run these scripts on macOS too.
- New scripts that are meant to be invoked by a harness command or a CI
  job should be referenced from that command/workflow file directly, not
  discovered implicitly.
