# Intent — v2.3.0: one image, three lifecycles

**Who:** an engineer who wants to run their team's AI development lifecycle inside the `fawkes-space` image without
rebuilding tooling: the Anthropic AI-native SDLC, AWS's AI-DLC, or Google's agent workflow.

**Job:** pick a lifecycle, get its tools, commands and review gates working in a fresh devcontainer, and keep one
intent → spec → plan artifact chain and one review rubric (`REVIEW.md`) whichever lifecycle runs.

**Why now:** v2.2.0 makes the Anthropic path complete (plan, build, verify, review, ship). AWS AI-DLC is only an opt-in
binary, Google's path is a Gemini CLI that Google is retiring, and the repo carries 272 tracked files that a third
lifecycle would add to.

**Outcome:** a user can follow one page per lifecycle to a working setup in under five minutes on a clean machine,
and the tracked file count goes down, not up.

**Not in scope:** replacing the four agents, or the v2 image contract.
