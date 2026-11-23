---
change: seam-enforcement-identity
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-22
approved_sha: 65137e4
---
# Seam phase 2: enforcement and agent identity: spec

Full design: `docs/ai-sdlc/sdlc-engine-seam/{spec,plan}.md`; this change implements phase 2 (#349, children #350 to #353).

## Requirements

- R6.1 `scripts/hooks/seam-gate.sh commit|push`, wired as pre-commit and pre-push hooks, blocks code-path changes while `sdlc-seam gate plan` fails; docs-only passes.
- R6.2, R6.3 The Claude Code and OpenCode shims call that script for `git commit` and `git push`, with no gate logic of their own.
- R6.4 `artifact-chain.yml` runs `sdlc-seam ci`, so a `--no-verify` push is red. Marked `feat!` for the next major.
- R6a Both harnesses set the bot identity; `check-harness-parity.sh` fails if they differ or one is missing; the bot is in `botIdentities`.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R6.1-R6.3 | integration | `bash scripts/test-sdlc-seam-hooks.sh`, `bash scripts/test-commit-matcher.sh` |
| R6a | unit | `bash scripts/test-harness-identity.sh` |
| R6.4 | live-system | throwaway PR pushed with `--no-verify` is red |
