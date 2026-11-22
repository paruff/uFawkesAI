---
change: seam-enforcement-identity
status: draft
author: ufawkes-bot@users.noreply.github.com
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
