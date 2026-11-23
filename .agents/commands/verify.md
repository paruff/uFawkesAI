---
description: Run verification gates and confirm output before claiming completion
agent: verifier
---
Run `scripts/sdlc-seam next`, then load the skill for the stage it names (review: `requesting-code-review`; ship: `verification-before-completion`). Back every claim with fresh output, then run `/review-local`; a HIGH finding fails the verification.
