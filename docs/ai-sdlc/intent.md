# Intent (v1) — uFawkesAI as a Dual-Harness AI-Native SDLC Template

Status: DRAFT — for review before spec.md is drafted.

## Problem Statement

uFawkesAI already has substantial AI-native SDLC scaffolding: a 14-agent
pipeline, 31 skill areas, a DORA-grounded golden path (`TEMPLATE-DESIGN.md`,
`docs/GOLDEN_PATH.md`), and partial dual-harness config (`opencode.json`,
`.opencode/`, `.claude/`, `rules/`, documented in `README-ai-sdlc.md`). It
does not yet reliably work as a template someone can clone and use, because
the dual-harness wiring has real gaps:

- The devcontainer (`.devcontainer/devcontainer.json`) only installs VS
  Code's GitHub Copilot extensions — neither the `opencode` CLI nor Claude
  Code is installed or configured inside it at all.
- Harness config can silently shadow itself. This session found and fixed
  one instance: a stale project-level `.opencode/commands/doctor.md` stub
  was shadowing the real, detailed global command, and its name collided
  with Claude Code's own built-in `/doctor` — renamed to `oc-health` to
  resolve both problems. Nothing currently catches this class of bug
  automatically.
- `README-ai-sdlc.md` documents the OpenCode side accurately as of this
  session's fixes, but has not been re-verified end-to-end (e.g. its
  `/doctor` reference is already stale after the rename above).

This initiative closes those gaps so uFawkesAI is a _provable_ template:
clone it, open the devcontainer, and both OpenCode and Claude Code work
immediately against the same skills, hooks, commands, rules, and MCP
servers — with no duplicated or conflicting config between the two.

uFawkesAI is also the first member of a planned "uFawkes suite" of
golden-path starter repos (siblings such as a future `python-fawkes-path`,
`java-fawkes-path`). It is not itself required to be usable for other
languages — its Node/TypeScript tooling stays as-is — but the _pattern_ it
demonstrates (how agents, skills, hooks, rules, and dual-harness config fit
together) is what those future siblings are expected to replicate in their
own stacks. This distinction matters for scope below.

## Users

**Primary:** a solo/indie developer doing AI-assisted development, cloning
uFawkesAI to start a new project, who wants a working AI-native SDLC —
skills, hooks, MCP servers, a devcontainer — from day one instead of
assembling one by hand.

**Secondary (not directly served by v1, but a design constraint):**
maintainers of future sibling golden-path repos in the uFawkes suite, who
will look to this repo's _pattern_ (not its specific npm commands) as the
model for their own stack's equivalent.

## Constraints

- Exactly two harnesses in scope for v1: **OpenCode** and **Claude Code**.
  Existing Cursor/Copilot/Gemini compatibility files (symlinks,
  `.cursorrules`, `copilot-instructions.md`) are left in place as-is but
  are not the focus of new work, and are not required to gain equivalent
  first-class treatment in this pass.
- No sample/demo application code. The "product" being templated is the
  SDLC tooling itself, not a business app — this applies to any new
  example content needed to prove a skill/hook/command works.
- No new CI/CD beyond one minimal workflow validating the harness's own
  configuration (`opencode.json`, MCP entries, Claude Code hooks/settings).
  This is not a deployment pipeline, and is additive to the existing
  `ci-quality.yml`, not a replacement for it.
- No cost/usage tracking dashboards, no multi-repo/monorepo orchestration.
  _(Not explicitly confirmed by the human partner — flagged below.)_
- Build on and reconcile with existing prior art rather than replace it:
  `TEMPLATE-DESIGN.md`'s DORA-grounded file map, `docs/GOLDEN_PATH.md`,
  `README-ai-sdlc.md`, the existing `.agents/` pipeline, and the existing
  `opencode.json` / `.opencode/` / `.claude/` / `rules/` structure.
- This repo becomes the template **in place** — no separate repo, no
  migration step.

## Success Criteria

"Smoke-tested + automated check" bar for v1:

1. The devcontainer builds, and installs/configures **both** the
   `opencode` CLI and Claude Code inside it (not just VS Code Copilot
   extensions as today).
2. Once inside the devcontainer, both harnesses read the same underlying
   skills/hooks/commands/rules/MCP config, with no duplicated or
   conflicting definitions between them — the `doctor`/`oc-health`
   collision found this session is the prototype bug this must prevent.
3. Exactly one example each of an MCP server, a skill, a hook, a command,
   and a rule, each hand-verified to actually function under **both**
   harnesses — not merely present as a file.
4. A CI workflow runs an automated smoke test of #1–#3 on every push
   (extends or sits alongside the existing `ci-quality.yml`).
5. `README-ai-sdlc.md` is accurate end-to-end after this work lands
   (including the `oc-health` rename) and serves as the adopter quickstart.
6. `TEMPLATE-DESIGN.md`'s file map is extended, not replaced, to cover the
   new/changed dual-harness and devcontainer files.

## Open Questions

- Confirm: are cost/usage tracking and multi-repo/monorepo orchestration
  correctly excluded from v1, as assumed above? confirmed
- What happens to `CLAUDE.md`'s current framing ("Product: uFawkesAI —
  Agent orchestration framework for platform engineering") once the
  repo's primary identity leans further into being a template? Kept
  alongside the template framing, folded into it, or superseded? fold into
- Do the Cursor/Copilot/Gemini compatibility files stay actively
  maintained going forward, or are they effectively frozen now that
  OpenCode + Claude Code are the explicit v1 focus? actively maintained
- Are future sibling repos (`python-fawkes-path`, `java-fawkes-path`)
  scaffolded as part of a later initiative, or fully out of scope for
  anyone working from this repo? later initiative
