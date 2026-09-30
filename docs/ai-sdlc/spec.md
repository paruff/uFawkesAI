# Specification (v1) — uFawkesAI as a Dual-Harness AI-Native SDLC Template

Status: DRAFT — derived from `intent.md` (accepted, with inline answers to
its Open Questions: cost/multi-repo exclusion confirmed; `CLAUDE.md`'s
product framing folds into the template framing; Cursor/Copilot/Gemini
compatibility files stay actively maintained, not frozen; sibling repos
are a later initiative).

## Requirements

**R1 — Harness support tiers.**
OpenCode and Claude Code are first-class in v1: both are installed and
configured inside the devcontainer, and every shipped skill/hook/command/
rule/MCP server must be hand-verified working under both. Cursor, GitHub
Copilot, and Gemini CLI are acknowledged but not first-class: their
existing compatibility files (`.cursorrules`, `.github/copilot-instructions.md`,
symlinked from `AGENTS.md`) are kept actively maintained — updated
whenever `AGENTS.md` changes, not left to drift — but are not required to
gain feature parity with the OpenCode/Claude Code work in this pass (e.g.
new skills/hooks are not required to have a Copilot-specific equivalent).
Codex is not currently referenced anywhere in this repo and is out of
scope entirely for v1 — add it only as a future acknowledged-tier target
if it comes up.

**R2 — Canonical source per component type**, per the compatibility
research below (see Design Decisions): skills live once in `.claude/skills/`
(read natively by both harnesses, zero translation); rules live once in
`AGENTS.md` and nested `<dir>/AGENTS.md` files (OpenCode's native "Rules"
feature, symlinked as `CLAUDE.md` at every level exactly as the root
already is); commands and MCP servers are maintained as one paired
definition per harness plus a CI check that they haven't drifted apart;
hooks are shared logic (one script/module) with a thin per-harness
wrapper, because the two harnesses' hook APIs are not translatable
mechanically.

**R3 — MCP servers: default vs. opt-in.**
A server ships **enabled by default** only if it needs no secret AND has
every runtime dependency already installed by the devcontainer: only
`playwright` qualifies (local browser automation, no credentials, `npx`
already available). A server ships **opt-in** otherwise: `context7`
(`CONTEXT7_API_KEY`), `github` (`GITHUB_TOKEN`/`GITHUB_PERSONAL_ACCESS_TOKEN`),
`sentry` (`SENTRY_API_KEY`) need an external credential; `serena` needs no
credential but needs `uv`/`uvx` (Python), which the devcontainer does not
install — **correction, found by this session's `/review`**: `serena` was
originally specified as default-on here, but shipped that way it fails to
connect on every fresh clone (reproduced live in this session too), which
directly contradicts "works immediately after clone." It is opt-in
(`"enabled": false` in `opencode.json`) until either the devcontainer
installs `uv`, or an adopter installs it themselves. The one MCP server
used for success-criterion #3's hand-verified example is `playwright` —
the only one that's actually default-on and dependency-complete.

**R4 — Devcontainer installs and boundaries.**
The devcontainer installs the `opencode` CLI and Claude Code (currently
installs neither — only VS Code's Copilot extensions), pinned to specific
versions rather than "latest" at build time, running as the existing
non-root `remoteUser: node`. It must not bake in any of R3's opt-in
secrets; those are supplied by the adopter via environment variables at
runtime, never committed or baked into the image.

**R5 — Anti-shadowing check.**
A CI step (or a `postCreateCommand` smoke check) detects the class of bug
this session found and fixed by hand (a stale `.agents/commands/doctor.md`
stub shadowing the real global command and colliding with Claude Code's
built-in `/doctor`): any command/skill name that exists in more than one
discovery path for a given harness, or that collides with a harness's own
reserved/built-in names, fails the check.

**R6 — CI smoke test.**
One workflow, additive to the existing `ci-quality.yml`, exercises
success criteria #1–#3 automatically on every push: build the devcontainer
(or an equivalent minimal environment), confirm both CLIs are present and
read the same config, and exercise the one example skill/hook/command/
MCP server/rule.

**R7 — Documentation stays accurate.**
`README-ai-sdlc.md` is corrected (its `/doctor` reference is already
stale after this session's `oc-health` rename) and becomes the adopter
quickstart. `TEMPLATE-DESIGN.md`'s file map is extended with rows for the
devcontainer changes and any new canonical-source files, not replaced.

**R8 — `CLAUDE.md` identity.**
Per the accepted answer "fold into": Section 2 ("Project Identity") is
rewritten so the existing "agent orchestration framework" framing and the
template framing are one statement, not two competing ones — e.g. "uFawkesAI
is an agent orchestration framework, packaged as a template so its
patterns are directly reusable," rather than listing both separately.

## Design Decisions

**Compatibility research (verified against each harness's own
documentation, not assumed):**

| Component | Claude Code | OpenCode | Canonical source | Translation |
|---|---|---|---|---|
| Rules/instructions | `CLAUDE.md`, + nested `<dir>/CLAUDE.md` | `AGENTS.md` ("Rules" feature), + nested `<dir>/AGENTS.md`, identical scoping behavior | `AGENTS.md` at every level | None — extend the existing root symlink pattern (`CLAUDE.md → AGENTS.md`) into every nested directory that gets one |
| Skills | `.claude/skills/<name>/SKILL.md` | Reads `.claude/skills/<name>/SKILL.md` natively (documented cross-compatibility) | `.claude/skills/` | None |
| Commands | `.agents/commands/<name>.md` (frontmatter: `description`, `allowed-tools`, `argument-hint`, `model`; body uses `$ARGUMENTS`) | `.agents/commands/<name>.md` (frontmatter: `description`, `agent`) | One paired command per name, one file per harness | Small — mostly frontmatter field mapping; enforce with a CI check that every command name exists under both paths with matching `description` |
| MCP servers | `.mcp.json` → `mcpServers: {name: {command, args, env}}` (stdio) or `{type:"http", url, headers}` | `opencode.json`/`.jsonc` → `mcp: {name: {type:"local", command:[...], env}}` or `{type:"remote", url, headers}` | Hand-maintained pair | Small — mechanical (`command`+`args` split/join, add/drop `type`); enforce with the same CI drift check as commands |
| Hooks | `.claude/settings.json` `hooks{}` — declarative: event → matcher → shell command | `.opencode/plugins/*.ts` — imperative TypeScript via the `@opencode-ai/plugin` SDK | Shared logic in one script/module | Real — the two APIs are structurally different (declarative vs. imperative); each harness gets a thin wrapper that calls the same underlying logic, not a generated file |

**Reference-architecture note:** I could not independently confirm a
project literally named "freeharness" in research for this spec. What I
did confirm, across multiple independent sources (including this
project's own `ecc` plugin, which already ships capability-limited
adapters translating one config into Claude Code's `CLAUDE.md`, Cursor's
rules, and OpenCode's `AGENTS.md`), is the same underlying pattern: single
canonical source, thin per-harness adapters, never edit the generated
side by hand. The design above follows that pattern per-component rather
than as one monolithic adapter, because — as the table shows — only two
of the five component types (commands, MCP servers) actually need a
generated/mapped adapter; two more (skills, rules) need none because both
harnesses already converge on the same file; and hooks need hand-written
parallel logic because the two harnesses' capabilities aren't equivalent,
not because of an implementation gap.

**MCP default/opt-in policy:** see R3. This is a design decision, not
just a requirement restated, because it fixes a real ambiguity: today all
four `opencode.json` servers are configured identically regardless of
whether they need a secret, so `context7`/`github`/`sentry` silently fail
auth for any fresh clone (confirmed in this session's `/doctor` run — all
three keys unset). Splitting default vs. opt-in makes that failure mode
disappear for the servers a new adopter is most likely to hit first.

## Security/Policy Constraints

- No opt-in MCP server's secret (R3) is ever baked into the devcontainer
  image, a committed file, or a default value — it is read from the
  environment at runtime only, consistent with this repo's existing "no
  secrets in any file" hard rule.
- The devcontainer's CLI installs (R4) are version-pinned, not `@latest`,
  so a template clone doesn't silently pick up an untested harness release
  the day it ships.
- A shared hook-logic module (Design Decisions, Hooks row) must produce
  the **same protected-path/security behavior** under both harnesses' thin
  wrappers — e.g. if the Claude Code side blocks edits to `.env`/`*.pem`/
  `*.key`/`credentials.*`, the OpenCode plugin wrapper must enforce the
  identical list, not a weaker approximation. This should be asserted by
  the CI smoke test (R6), not left to manual review.

## UX Considerations

- `README-ai-sdlc.md` (R7) is the single quickstart entry point — an
  adopter should never need to read `TEMPLATE-DESIGN.md`'s full DORA
  rationale just to get both harnesses running.
- The anti-shadowing check (R5) gives a clear, specific error naming the
  colliding files/names, not just "something is wrong" — this session's
  manual diagnosis (tracing `doctor` through `opencode debug config`) is
  the failure mode a future adopter should never have to repeat by hand.
- Command naming: given R5, a new command name should be checked against
  both harnesses' reserved/built-in names before being added, not just
  against this repo's own existing commands.

## Flagged Concerns

- **Hooks are genuine ongoing dual-maintenance**, not a one-time
  migration cost — any future hook logic change must be applied to both
  the Claude Code wrapper and the OpenCode plugin wrapper. The CI drift
  check (R6/Design Decisions) should cover hooks too if practical, even
  though — unlike commands/MCP servers — there's no simple structural
  equivalence to diff; at minimum, flag when one wrapper changes without
  the other in the same commit.
- **"freeharness" is unconfirmed** (see Design Decisions note) — if you
  have a specific link or repo in mind, share it and I'll re-check this
  spec against it for anything missed.
- The `~/.claude/rules/ecc/*.md` files this session observed loading into
  context are **user-global, not part of this repo** — they are out of
  scope for this template entirely. The project's own top-level `rules/`
  directory (the ECC rule pack copied into this repo) is what R2's
  nested-`AGENTS.md` treatment applies to, and needs a decision in
  `plan.md` about which specific rule files become which nested
  `AGENTS.md` files.
- R3's default/opt-in split is a recommendation based on what's
  configured today — it hasn't been separately confirmed the way
  `intent.md`'s open questions were. Flagging it here rather than in
  Open Questions since `spec.md` doesn't have that section; treat it as
  provisional until you confirm it.
