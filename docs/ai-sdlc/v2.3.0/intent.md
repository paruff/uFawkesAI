# Intent — v2.3.0: one image, two lifecycles

**Who:** an engineer who wants to run their team's AI development lifecycle inside the `fawkes-space` image without
rebuilding tooling: the Anthropic AI-native SDLC or Google's agent workflow. (AWS AI-DLC was dropped on 2026-11-05;
see `docs/ai-sdlc/remove-aidlc/plan.md`.)

**Job:** pick a lifecycle, get its tools, commands and review gates working in a fresh devcontainer, and keep one
intent → spec → plan artifact chain and one review rubric (`REVIEW.md`) whichever lifecycle runs.

**Why now:** v2.2.0 makes the Anthropic path complete (plan, build, verify, review, ship). Google's path is a Gemini CLI
that Google has retired for most individual users, and the repo carries 272 tracked files that a second lifecycle
would add to.

**Outcome:** a user can follow one page per lifecycle to a working setup in under five minutes on a clean machine,
and the tracked file count goes down, not up.

**Not in scope:** replacing the four agents, or the v2 image contract.
