---
description: Run verification gates and confirm output before claiming completion
agent: verifier
---
Run `scripts/sdlc-seam next`, then load the skill for the stage it names (review: `requesting-code-review`; ship: `verification-before-completion`). Report each gate as `✅ [Command] [X passed, Y failed] "Claim"` with fresh output, never "should pass", then run `/review-local`; a HIGH finding fails the verification.
