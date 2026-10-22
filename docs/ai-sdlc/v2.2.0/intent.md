# Intent — v2.2.0: fawkes-space for the Anthropic AI-native SDLC

**Who:** an engineer using the `fawkes-space` devcontainer, and the suite repos that pin it.

**Job:** take a change from intent to merged PR inside one image, with each stage
owned by one agent and reviewed twice: locally before commit, then in CI.

**Why now:** the image trails its harnesses (OpenCode 1.19.3 vs 2.1.2, Claude Code
2.1.293 vs 2.1.308, Superpowers 7.0.0 vs 7.0.1), review exists only after the PR is
open, and `sync.sh` can overwrite a host's own OpenCode config.

**Outcome (DORA):** shorter lead time and lower change failure rate: review findings
land before the commit, not in a PR round trip.

**Not in scope:** AWS AI-DLC stays opt-in; no change to the v2 contract's image name or tags.
