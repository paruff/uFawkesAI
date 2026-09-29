# Global agent stance (all repos) — DORA AI Capability 1: Clear and communicated AI stance

Installed to `~/.config/opencode/AGENTS.md` by `opencode/sync.sh` from
paruff/uFawkesAI. Loaded into every OpenCode session in every repo, so it holds
only what is true everywhere; each repo's own `AGENTS.md` wins on specifics.

## Hard rules

- Read the repo's `AGENTS.md` first, then its intent (`docs/ai-sdlc/intent.md` or `INTENT.md`) if present.
- Verify against `main` before saying "done": content check + CI green.
- One PR per change, small batches (< 400 lines).
- Agents never merge — a human reviews and merges.
- Never commit secrets; never bypass hooks (`--no-verify`).
- Use `ruff` for Python formatting/linting.

## Methodology

- Superpowers skills are the development loop (brainstorming → writing-plans →
  executing-plans / test-driven-development → verification-before-completion →
  requesting-code-review; systematic-debugging for failures).
- `.agents/` is hidden from glob search — open files there by explicit path.
