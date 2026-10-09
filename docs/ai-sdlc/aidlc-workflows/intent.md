# Intent — AWS AI-DLC as an Opt-In Tool in the CDE Image

Status: DRAFT (originator: repo owner, 2026-10-09)

## Problem

[awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (AI-DLC,
MIT-0, v2.11.0 on 2026-10-08) is a harness-neutral lifecycle engine: one
`aidlc` command, 14 agents, 33 stages, approval gates and an audit trail, for
Claude Code, OpenCode, Codex, Cursor, Copilot and Kiro. Teams who build from
this template may want to try it. Today they have to `curl | sh` it into each
container, unpinned and unverified, which the image exists to prevent.

It also overlaps with what this template already is. AI-DLC is a second
lifecycle: its own stages, agents and `aidlc/` artifact folder, beside our
`intent → spec → plan` chain, four agents and the artifact-chain gate.
`aidlc config` writes hooks into `.claude/settings.json`, a harness tree into
`.claude/` or `.opencode/`, and lines into `AGENTS.md`, all of which
`AI_STANCE.md` governs. Nobody has run the two side by side, so we don't know
whether AI-DLC should stay a separate tool, feed our chain, or replace it.

## Desired Outcome

1. The `ai` image variant ships `aidlc` pinned and checksum-verified like
   every other locked tool, kept current by the existing lock-bump workflow.
2. Nothing is configured by default. A team opts in per repo with one
   documented command, and sees what it will write before it writes.
3. One real run in a repo made from the template shows what AI-DLC writes,
   what it costs, and whether the artifact-chain gate still passes, so the
   lifecycle question is decided on evidence.

## Decisions Already Made

- **A tool, not the lifecycle.** The template's own chain stays the default
  and the gate. Whether AI-DLC feeds or replaces it is decided after the run
  (spec D2), not here.
- **The `ai` variant only.** That's where the agent harnesses (OpenCode,
  Codex, Gemini CLI, Claude Code) already live. `core` stays harness-free.
- **Ships in v2.1.0**, after v2.0.0 is tagged. It's additive and must not
  grow the v2.0.0 contract.
- **Routed to Claude Code** (`goal`): it touches the image supply chain and
  ends in a methodology decision.

## Out of Scope

- Running `aidlc config` in this repo or committing any AI-DLC files here.
- Changing `AGENTS.md`, `.claude/settings.json` or `.opencode/` in the
  template.
- Model provider setup (Bedrock etc.): that belongs to the harness.
- Windows and macOS installs: the image is Linux only.
