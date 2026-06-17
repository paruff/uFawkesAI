---
name: context-engineering
description: "Ensure graphify corpus is current and complete before each agent session. Define minimum AI-accessible documentation per repo. Use at session startup to verify internal context is available to AI tools. Implements DORA AI Capability 3."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Context Engineering

> **Load trigger:** `"load context-engineering skill"`
> **DORA:** AI Capability 3 (AI-accessible internal data)
> **Token cost:** Low

## Purpose

Move AI tools from generic assistants to specialized experts by connecting them to
internal documentation and codebase structure. "Context engineering" is the practice
of deliberately managing what internal knowledge is available to AI tools at session
start — not just what prompt you give them.

DORA AI Capabilities Model v2025.1: "Connecting AI to your internal documentation
and codebases moves it from a generic assistant to a specialized expert."

This skill eliminates the "re-discover context every session" tax — particularly
costly at 2hrs/day across an 8-repo portfolio.

## Graphify Variant Note

**⚠ Confirm before use:** Two different tools share the name "graphify":

- `safishamsi/graphify` — knowledge graph from code structure
- `rhanka/graphify` — graph visualization tool

These have different CLI syntax. This skill uses `[graphify-cli]` as a placeholder.
Replace with the actual command after confirming which variant is installed:

```bash
# Check which is installed
which graphify && graphify --version
# Or check package.json / pyproject.toml for the dependency
```

## Minimum Corpus per Repo

Every uFawkes\* repo must maintain these files for AI-accessible context.
Missing files are flagged as corpus gaps, not silently ignored.

| File                                        | Required                         | Purpose                                       |
| ------------------------------------------- | -------------------------------- | --------------------------------------------- |
| `README.md`                                 | ✅ Mandatory                     | What this is, quick start, current status     |
| `AGENTS.md`                                 | ✅ Mandatory                     | Agent suite, skill list, handoff protocol     |
| `ARCHITECTURE.md` or `docs/ARCHITECTURE.md` | ✅ Mandatory                     | System design, component relationships        |
| `CONTRIBUTING.md`                           | ✅ Mandatory                     | How to contribute — must not be a placeholder |
| `AI_STANCE.md`                              | ✅ Mandatory                     | AI policy (see ai-stance skill)               |
| `tests/README.md` or equivalent             | ✅ Mandatory                     | How to run tests, what they cover             |
| `CHANGELOG.md`                              | ✅ Mandatory                     | Release history                               |
| `DORA-event-format.md`                      | ⚠ Required when uFawkesObs wired | Deployment event schema for DORA metrics      |
| `docs/PROMPT_LIBRARY.md`                    | Optional                         | Tested prompt templates (see uFawkesObs)      |

## Per-Repo Corpus Extensions

Beyond the minimum, each repo has domain-specific files that should be in the corpus:

| Repo          | Additional corpus files                                                                                    |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| `fawkes`      | `.agents/` directory tree, `ROADMAP.md`, `.opencode/plans/roadmap.md`, `.gitops-templates/`                |
| `uFawkesObs`  | `docs/ARCHITECTURE.md`, `PROMPT_LIBRARY.md`, `tests/acceptance/` structure, `docs/production-hardening.md` |
| `uFawkesAI`   | Full `.agents/skills/` directory tree, all agent `.md` files                                               |
| `uFawkesPipe` | Pipeline definition files (`.woodpecker.yml` or `Jenkinsfile`), `docker-compose.yml`                       |
| `uFawkesDevX` | `devcontainer.json`, golden path templates                                                                 |
| `uFawkesDORA` | Dashboard JSON, metric query definitions                                                                   |
| `uFawkesSec`  | Policy definitions (OPA Rego or Kyverno), threat model                                                     |
| `uFawkes.dev` | `_config.yml`, `_data/`, navigation structure, `SKILL.md` files under `.agents/`                           |

## Session Startup Checklist

Run at the start of every opencode session involving more than one file change.
Takes under 2 minutes. Prevents context-blind agent decisions.

```bash
# 1. Check corpus last-built timestamp
# [graphify-cli] status --repo . --json | jq '.last_built'
# Warn if > 24 hours stale

# 2. Verify minimum corpus files exist
for f in README.md AGENTS.md CONTRIBUTING.md AI_STANCE.md CHANGELOG.md; do
  [ -f "$f" ] || echo "CORPUS GAP: $f missing"
done

# Check for ARCHITECTURE.md in either location
[ -f "ARCHITECTURE.md" ] || [ -f "docs/ARCHITECTURE.md" ] || \
  echo "CORPUS GAP: ARCHITECTURE.md missing (check docs/ too)"

# Check for test README
[ -f "tests/README.md" ] || [ -f "tests/TESTING.md" ] || \
  echo "CORPUS GAP: test suite documentation missing"

# 3. Check AGENTS.md references current skill list
# (Agent should read AGENTS.md and verify all listed skills exist in .agents/skills/)

# 4. Rebuild corpus if stale or gaps found
# [graphify-cli] build --repo . --include "*.md,*.yaml,*.yml,*.json" --exclude "node_modules,vendor,.git"
```

## Corpus Quality Signals

These indicate the corpus will give poor context — flag them, don't silently continue:

| Signal                                                                  | Problem                                 | Remediation                              |
| ----------------------------------------------------------------------- | --------------------------------------- | ---------------------------------------- |
| `CONTRIBUTING.md` contains `[Add contribution guidelines here]`         | Placeholder — agents read wrong content | Fill CONTRIBUTING.md before session      |
| `README.md` "Status" section missing                                    | Agent doesn't know current state        | Add Status section                       |
| `AGENTS.md` references skills that don't exist                          | Stale skill list                        | Update AGENTS.md or create missing skill |
| ARCHITECTURE.md last modified > 90 days ago + recent structural changes | Stale architecture                      | Update ARCHITECTURE.md                   |
| `AI_STANCE.md` last reviewed > 90 days ago                              | Stale policy                            | Run ai-stance audit sub-skill            |

## Span Events

Emit these telemetry spans (integrates with `agent-observability` skill):

| Span                      | When                       | Attributes                            |
| ------------------------- | -------------------------- | ------------------------------------- |
| `context.corpus.verified` | Startup check complete     | `repo`, `corpus_current`, `gap_count` |
| `context.corpus.gap`      | A required file is missing | `repo`, `missing_file`                |
| `context.corpus.stale`    | Corpus > 24hrs old         | `repo`, `hours_stale`                 |
| `context.corpus.rebuilt`  | Corpus rebuild triggered   | `repo`, `files_indexed`               |

## Output Format

```json
{
  "skill": "context-engineering",
  "repo": "paruff/REPO_NAME",
  "corpus_current": true,
  "last_built": "2026-06-16T08:00:00Z",
  "hours_stale": 2,
  "missing_files": [],
  "corpus_quality_warnings": [],
  "pending_skills": ["dora-measurement", "j-curve-navigation"],
  "ready_for_session": true
}
```

## Sub-Skills

| Sub-skill                     | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| `context-engineering/startup` | Run the session startup checklist              |
| `context-engineering/audit`   | Full corpus audit across all 8 uFawkes\* repos |
| `context-engineering/rebuild` | Force corpus rebuild with current file set     |
