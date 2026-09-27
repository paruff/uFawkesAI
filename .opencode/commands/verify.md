---
description: Run verification gates and confirm output before claiming completion
agent: verifier
---
Load `superpowers/verification-before-completion` if available.
Run typecheck, lint, test, and build gates.
Capture full output and report with evidence.
Do not claim success without fresh output.
Use: `✅ [Command] [X passed, Y failed] "Claim"`.
Never say "should pass" or "looks correct".
