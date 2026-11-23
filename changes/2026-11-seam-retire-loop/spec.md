---
change: seam-retire-loop
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam phase 3: retire the hand-built loop: spec

Implements R5 of docs/ai-sdlc/sdlc-engine-seam/spec.md (issue #354).

- Remove check-artifact-chain.sh and test-artifact-chain.sh (replaced by `sdlc-seam ci`).
- Commands plan, implement, ship, verify, tdd become one-paragraph pointers to `sdlc-seam next`.
- Agent files drop gate prose and call `sdlc-seam gate`.

## Verification Strategy

scripts/run-unit-tests.sh and pre-commit run --all-files pass.
