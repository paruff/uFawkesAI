# Implementation Plan (v1) — uFawkesAI as a Dual-Harness AI-Native SDLC Template

Status: DRAFT — derived from `spec.md`, plus the decision spec.md deferred
here: the 4 existing `rules/*.md` files (topic-scoped: testing, security,
api-design, gitops) become **skills**, not nested `AGENTS.md` files — they
apply by task type, not by directory, and this repo has no sample-app
directory structure to scope a nested `AGENTS.md` to. A nested `AGENTS.md`
is still needed to demonstrate that mechanism at all (the "rule" example
from success criterion 3), so one is added under the one real non-app
directory that already exists: `scripts/`.

## Files to Change

All 11 items are implemented (2026-09-26).

- [x] `docs/KNOWN_LIMITATIONS.md` — add an entry documenting the hooks
      dual-maintenance limitation (per your "document known limitations"
      answer): the protected-path list becomes shared, but the formatter
      dispatch table and the `SessionStart` reminder message remain
      separately implemented per harness (JSON hook config vs. TS plugin
      code) because the two hook APIs aren't structurally equivalent.
- [x] `scripts/hooks/protected-paths.json` — new. Extracted shared list.
      Note for the plan record: the two existing implementations
      (`.claude/settings.json`'s inline regex and
      `.opencode/plugins/ai-sdlc-hooks.ts`'s `PROTECTED_BASENAME`) already
      matched exactly — this didn't fix a bug, it made that agreement
      enforced instead of coincidental. Verified: blocks `.env.local`,
      allows `src/index.ts`.
- [x] `.claude/settings.json` — PreToolUse/PostToolUse `Edit|Write` hook
      commands read the shared JSON instead of an inline regex list.
- [x] `.opencode/plugins/ai-sdlc-hooks.ts` — `PROTECTED_BASENAME` imports
      the same shared JSON instead of its own inline array.
- [x] `.opencode/skills/testing-rules/SKILL.md`,
      `.opencode/skills/security-rules/SKILL.md`,
      `.opencode/skills/api-design-rules/SKILL.md`,
      `.opencode/skills/gitops-rules/SKILL.md` — migrated from
      `rules/testing.md`, `rules/security.md`, `rules/api-design.md`,
      `rules/gitops.md` respectively; content preserved, `name`/
      `description`/`compatibility` frontmatter added. **Correction to
      this plan's original path**: written under `.opencode/skills/`, not
      `.claude/skills/` — discovered mid-implementation that
      `.claude/skills` is already a pre-existing symlink to
      `.opencode/skills` (and `.agents/commands` to `.agents/commands`),
      so writing to the real target is required and the file is
      automatically visible at both paths with zero duplication.
- [x] `rules/*.md` (4 files) — removed, superseded by the skills above;
      replaced with a one-line `rules/README.md` pointing to the new
      skill locations so an old link doesn't 404 silently.
- [x] `scripts/AGENTS.md` + `scripts/CLAUDE.md` (symlink, matching the
      root's existing symlink pattern) — new. The "rule" example: loads
      only when working under `scripts/`, under both harnesses.
- [x] `.agents/commands/plan.md`, `verify.md`, `ship.md`, `review.md`,
      `tdd.md`, `implement.md` — **not needed**: same symlink discovery
      as above — `.agents/commands` already aliases `.agents/commands`,
      so these 6 commands were already dual-harness before this session
      touched anything. No new files created.
- [x] `.agents/commands/oc-health.md` — new project-level copy of the
      command this session renamed and left only at the user's personal
      `~/.config/opencode/commands/` scope. Without this, a fresh clone
      would not have had it. Automatically visible at
      `.agents/commands/oc-health.md` via the same symlink. Verified via
      `opencode debug config`'s discovered `command` keys.
- [x] `.mcp.json` — new. Claude Code's native MCP config, translating
      `opencode.json`'s `context7`/`github`/`playwright`/`sentry` entries
      into `.mcp.json`'s schema, plus adding `serena` (previously only in
      `opencode/opencode.jsonc`) so both harnesses offer the same server
      set.
- [x] `opencode.json` (root) — added `serena`; added `enabled: true/false`
      (a real field OpenCode already supports, per `serena`'s own prior
      entry) marking `playwright` default-on and
      `context7`/`github`/`sentry`/`serena` opt-in per R3 (**corrected by
      `/review`**: `serena` was initially marked default-on alongside
      `playwright`, but it needs `uv`/`uvx`, which the devcontainer never
      installs — it failed to connect even on this session's own host
      machine when tested live. Now opt-in like the credential-gated
      servers, for a different reason: missing runtime dependency, not
      missing secret). Verified via `opencode debug config`: all four opt-in
      servers report `enabled: false`. Note: `.mcp.json` has no equivalent verified
      toggle for Claude Code, so the opt-in servers there rely on the
      existing missing-env-var behavior rather than an explicit disable.
- [x] `scripts/check-harness-parity.sh` — new. The R5 anti-shadowing
      check: `.agents/commands`/`.claude/skills` are verified as intact
      symlinks to `.agents/commands`/`.opencode/skills` (not shadowing
      real directories); `.mcp.json` and `opencode.json` server name sets
      match; no command/skill name collides with a small (documented
      non-exhaustive) reserved-name list including `doctor`. Verified
      passing.
- [x] `.devcontainer/devcontainer.json` — `postCreateCommand` now also
      installs `opencode-ai@1.18.30` and `@anthropic-ai/claude-code@2.1.283`
      (version-pinned to this session's own verified versions) globally
      via npm; existing non-root `remoteUser: node` unchanged. Note: the
      exact devcontainer-friendly install commands were unverified at
      planning time (flagged as a Risk) — this uses npm global install,
      which is the most reliably pinnable method for both CLIs, but has
      not been proven inside an actual container build.
- [x] `.github/workflows/ci-quality.yml` — new `dual-harness-smoke` job
      (builds the devcontainer via `devcontainers/ci`, runs
      `scripts/dual-harness-smoke.sh` inside it — a new script covering
      every item in "Tests That Prove It" below); wired into
      `ci-summary`'s `needs`, failure check, and table. Existing jobs
      untouched. YAML validated.
- [x] `README-ai-sdlc.md` — fixed the stale `/doctor` reference
      (→ `/oc-health`, with an explanation of why they're separate now),
      documents the new commands/skills/MCP/hooks layout and the R3
      default-on/opt-in MCP policy.
- [x] `TEMPLATE-DESIGN.md` — file-map table extended with 8 new rows;
      existing rows untouched.
- [x] `AGENTS.md` (root, symlinked as `CLAUDE.md`) — Section 2 rewritten
      per R8: the "agent orchestration framework" and "template" framings
      folded into one statement; added a `Harnesses:` line. Verified the
      change propagates through the `CLAUDE.md`/`.cursorrules`/
      `copilot-instructions.md` symlinks automatically.
- [x] `.github/copilot-instructions.md`, `.cursorrules` — confirmed
      unchanged as files (still symlinks) and confirmed the Section 2
      content update above is visible through them, verifying R1's
      "actively maintained" holds automatically here.

## Order of Work

1. `docs/KNOWN_LIMITATIONS.md` — no dependencies, do first.
2. Hook parity: shared JSON, then both hook implementations read it.
3. Skills migration: create the 4 skills, verify content parity with the
   originals, then remove `rules/*.md` and add `rules/README.md`.
4. `scripts/AGENTS.md` + symlink (the rule example).
5. Commands: create the 6 `.agents/commands/*.md` pairs, then
   `.agents/commands/oc-health.md`.
6. MCP: `.mcp.json`, then reconcile `opencode.json`'s annotations against
   it.
7. `scripts/check-harness-parity.sh` — written after 3/5/6 exist, since
   it checks their output; run it locally and fix any drift it finds
   before moving on.
8. `.devcontainer/devcontainer.json`.
9. `.github/workflows/ci-quality.yml` new job — depends on both the
   parity script (7) and the devcontainer (8) existing.
10. Docs catch-up: `README-ai-sdlc.md`, then `TEMPLATE-DESIGN.md`'s file
    map — written last so they describe what actually landed, not what
    was planned.
11. `AGENTS.md` Section 2 identity rewrite (R8) — independent of the rest,
    can happen any time, placed last here only because it's the lowest-risk
    item to leave for a final pass.

## Risks

- **Devcontainer install commands for both CLIs aren't fully verified at
  planning time.** The exact `opencode`/Claude Code install steps that
  work cleanly inside a `javascript-node:22`-based devcontainer need to be
  worked out during implementation, not assumed here.
- ~~`serena` needs `uv`/`uvx` (Python), which the current devcontainer
  image doesn't have.~~ **This risk materialized and was fixed by
  `/review`**: `serena` was shipped default-on before the devcontainer
  install step existed, failed to connect (reproduced live, not just
  theoretically), and is now opt-in (`opencode.json`'s `enabled: false`)
  instead. Installing `uv` in the devcontainer so it can go back to
  default-on is a legitimate future improvement, not a blocker.
- **Version pins (R4) will go stale.** Pinning `opencode`/Claude Code
  versions in the devcontainer is right for reproducibility but creates an
  ongoing maintenance task (bump the pin, re-verify the smoke test) that
  nothing here automates.
- **Devcontainer builds inside CI can be slow or flaky.** The smoke test
  (R6) may need `devcontainers/ci` or an equivalent action rather than a
  naive `docker build`, and will add real minutes to CI runtime.
- **The hook unification is partial, not full** (see the
  `KNOWN_LIMITATIONS.md` entry above) — only the protected-path list is
  shared; the formatter dispatch and the `SessionStart` message stay
  separately implemented per harness and can still drift silently between
  them. The parity script (item 7) does not currently check this, since
  there's no simple structural diff for hook *behavior* the way there is
  for command/MCP *definitions*.
- **Migrating `rules/*.md` to skills changes their loading model** from
  "always readable by `cat`ing the file" to "on-demand, matched by the
  skill's `description`." If a description doesn't reliably trigger when
  actually relevant, the content is effectively invisible even though the
  file exists — this needs real usage, not just a presence check, to
  validate; the smoke test below only proves the skill loads when asked
  for by name, not that it would be found unprompted.

## Verification Strategy (tests that prove it)

Per your instruction, "tests" for a template repository means an
end-to-end smoke test against a fresh clone, run automatically in CI —
not unit tests against application code (there is none).

**Status:** `scripts/dual-harness-smoke.sh`'s logic is written and passes
when run directly on the host machine (verified this session — every
check below currently passes). It has **not** yet been run inside an
actual freshly built devcontainer via the new `dual-harness-smoke` CI
job — that only happens on a real push/PR, which hasn't occurred yet.
The two checkbox groups below reflect this distinction.

- [ ] Fresh clone (a clean checkout in CI, not a pre-configured
      developer machine) builds the devcontainer successfully. **Unverified**
      — the devcontainer install commands (R4's Risk) haven't been proven
      in an actual container build yet.
- [x] Inside the built devcontainer, `opencode --version` and
      `claude --version` both succeed — both CLIs present (R4).
      Verified on host (both already installed at the pinned versions);
      not yet verified via a fresh devcontainer build.
- [x] **OpenCode**: `/plan`, `/verify`, `/ship`, `/oc-health` all appear
      in `opencode debug config`'s discovered `command` keys. Verified.
- [x] **Claude Code**: `/plan`, `/verify`, `/ship` are discoverable as
      project commands (`.agents/commands/*.md` present via symlink).
      `/doctor` resolves to Claude Code's own built-in — verified no
      `.agents/commands/doctor.md` and no `.claude/skills/doctor/` exist
      anywhere in the repo (the regression test for the exact bug this
      session found by hand).
- [x] One MCP server (`playwright`, no secret required) responds — verified
      invocable (`npx -y @playwright/mcp --help`) and present in both
      `opencode.json` and `.mcp.json`.
- [x] One skill (`testing-rules`) is present at both `.claude/skills/` and
      `.opencode/skills/` paths (loadable by name under both harnesses).
- [x] One hook (the protected-path blocker) actually blocks an edit to a
      `.env` file — verified via direct simulation of the hook logic.
- [x] One command (`/verify`) has its definition present at both
      `.agents/commands/verify.md` and (via symlink) `.agents/commands/verify.md`.
- [x] One rule (`scripts/AGENTS.md`) exists with `scripts/CLAUDE.md`
      correctly symlinked to it — the directory-scoping behavior itself
      (loads under `scripts/`, absent elsewhere) is a harness runtime
      behavior, not independently verifiable from the shell.
- [x] `scripts/check-harness-parity.sh` exits 0 — verified, no drift.
- [ ] All of the above run as one CI job (`dual-harness-smoke`) on every
      push. **Unverified** — the job is written and wired into
      `ci-summary`, and its YAML is syntax-valid, but it has not yet
      executed in actual GitHub Actions (no push/PR has triggered it).

## Rollback Plan

- Every change is additive except the 4 `rules/*.md` files, which are
  superseded by skills with their content preserved verbatim — reverting
  the migration commit restores them instantly via `git revert`.
- The devcontainer change is isolated to `.devcontainer/devcontainer.json`;
  reverting that one file alone restores today's Copilot-only setup
  without touching anything else in this plan.
- The new CI job (`dual-harness-smoke`) is additive to `ci-quality.yml`;
  if it proves too flaky or slow, it can be disabled or removed on its
  own without affecting the existing `preflight`/`lint`/`typecheck`/
  `test`/`architecture` jobs.
- The hook refactor (shared JSON) and the MCP reconciliation both touch
  already-working files; each is a small enough diff to revert
  independently if either harness's hook or MCP behavior regresses.
