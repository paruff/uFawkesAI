---
change: seam-enforcement-identity
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-22
approved_sha: 1172dc0
---
# Seam phase 2: enforcement and agent identity: plan

Full design: `docs/ai-sdlc/sdlc-engine-seam/{spec,plan}.md`; this change implements phase 2 (#349, children #350 to #353).

## Steps
1. Identity: `.claude/settings.json` env, OpenCode `shell.env`, parity check (#350).
2. Git gate script and pre-commit hooks (#351).
3. Claude Code and OpenCode shims (#352).
4. `artifact-chain.yml` runs `sdlc-seam ci` (#353).

The code is already written and its self-tests pass, awaiting this plan's approval to be committed.

## Verification Strategy
See spec.md: the three self-tests, then the live `--no-verify` PR.

## Verification

- R6.1: `bash scripts/test-sdlc-seam-hooks.sh` (commit and push blocked on an unapproved plan, docs-only passes)
- R6.2: `bash scripts/test-sdlc-seam-hooks.sh` (Claude Code shim blocks git commit and git push, ignores commit-tree)
- R6.3: `bash scripts/test-sdlc-seam-hooks.sh` and `bash scripts/test-commit-matcher.sh` (OpenCode plugin, matcher parity)
- R6.4: throwaway PR pushed with `--no-verify` shows a red `CI Complete`
- R6a: `bash scripts/test-harness-identity.sh` (parity check and plain-shell identity)
