---
name: documentation/cross-repo-links
description: "Add the Suite Context section to all uFawkes* repos that are missing it. Directly implements roadmap item 0.6. Run once to establish the links, then quarterly to keep them current. Each repo takes under 5 minutes."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: documentation
---

# Sub-Skill: Documentation — Cross-Repo Links

> **Load trigger:** `"load documentation/cross-repo-links skill"`
> **DORA:** AI Capability 3 (AI-accessible internal data)
> **Token cost:** Low
> **When to use:** Implementing roadmap item 0.6, or when suite-audit shows missing suite links.

## Purpose

Implement roadmap item 0.6: "Add cross-repo links in all READMEs." Every uFawkes\*
repo README should have a Suite Context section that tells any reader (human or agent)
exactly where this repo fits in the portfolio, with working links to all related repos.

This is the single highest-leverage documentation action for AI-accessibility: an
agent reading any repo's README can immediately find all related context.

## The Standard Suite Context Block

This exact block goes into every uFawkes\* repo README under `## Suite Context`.
Update the "This repo" row to describe the specific repo.

```markdown
## Suite Context

This repo is part of the [uFawkes platform suite](https://ufawkes.dev) — an open-source
internal developer platform for small engineering teams.

| Repo                                                 | Role in suite                                                    |
| ---------------------------------------------------- | ---------------------------------------------------------------- |
| **[fawkes](https://github.com/paruff/fawkes)**       | Core IDP — orchestrates the full platform stack                  |
| [uFawkesObs](https://github.com/paruff/uFawkesObs)   | Observability substrate (OTel, Prometheus, Grafana, Loki, Tempo) |
| [uFawkesPipe](https://github.com/paruff/uFawkesPipe) | Lightweight CI/CD (Woodpecker CI + Portainer)                    |
| [uFawkesDevX](https://github.com/paruff/uFawkesDevX) | Developer experience (CDE, golden paths, Backstage-alternative)  |
| [uFawkesDORA](https://github.com/paruff/uFawkesDORA) | DORA metrics dashboards and delivery benchmarks                  |
| [uFawkesSec](https://github.com/paruff/uFawkesSec)   | Security posture (policy-as-code, supply chain)                  |
| [uFawkesAI](https://github.com/paruff/uFawkesAI)     | AI agent and skill suite for the product lifecycle               |
| [uFawkes.dev](https://ufawkes.dev)                   | Documentation site and Dojo (five-belt learning curriculum)      |

**Portfolio roadmap:** [fawkes/ROADMAP.md](https://github.com/paruff/fawkes/blob/main/ROADMAP.md)
**Learning:** [Fawkes Dojo](https://ufawkes.dev/dojo) — White through Black Belt curriculum
```

## Per-Repo "This Repo" Row

Bold the current repo's row and add a short description specific to it:

| Repo        | This repo description                                |
| ----------- | ---------------------------------------------------- |
| fawkes      | **This repo** — Core IDP                             |
| uFawkesObs  | **This repo** — Observability substrate              |
| uFawkesPipe | **This repo** — Lightweight CI/CD                    |
| uFawkesDevX | **This repo** — Developer experience and CDEs        |
| uFawkesDORA | **This repo** — DORA metrics and delivery benchmarks |
| uFawkesSec  | **This repo** — Security posture                     |
| uFawkesAI   | **This repo** — AI agent and skill suite             |
| ufawkes.dev | **This repo** — Documentation site and Dojo          |

## Implementation Script

```bash
#!/usr/bin/env bash
# Run from the repo root
# Set REPO_NAME to match the table above

REPO_NAME="${1:-$(basename $(git rev-parse --show-toplevel))}"

# Check if Suite Context already exists
if grep -q "Suite Context" README.md 2>/dev/null; then
  echo "ℹ  Suite Context section already present in README.md"
  echo "   Run diff to check if it's current: diff <(grep -A 20 'Suite Context' README.md) <(echo STANDARD_BLOCK)"
  exit 0
fi

# Determine "this repo" description
declare -A REPO_DESCRIPTIONS=(
  ["fawkes"]="**This repo** — Core IDP — orchestrates the full platform stack"
  ["uFawkesObs"]="**This repo** — Observability substrate (OTel, Prometheus, Grafana, Loki, Tempo)"
  ["uFawkesPipe"]="**This repo** — Lightweight CI/CD (Woodpecker CI + Portainer)"
  ["uFawkesDevX"]="**This repo** — Developer experience (CDE, golden paths)"
  ["uFawkesDORA"]="**This repo** — DORA metrics dashboards and delivery benchmarks"
  ["uFawkesSec"]="**This repo** — Security posture (policy-as-code, supply chain)"
  ["uFawkesAI"]="**This repo** — AI agent and skill suite for the product lifecycle"
  ["ufawkes.dev"]="**This repo** — Documentation site and Dojo (five-belt learning curriculum)"
)

THIS_REPO_DESC="${REPO_DESCRIPTIONS[$REPO_NAME]:-**This repo**}"

# Append Suite Context section to README
cat >> README.md << SUITE_CONTEXT

## Suite Context

This repo is part of the [uFawkes platform suite](https://ufawkes.dev) — an open-source
internal developer platform for small engineering teams.

| Repo | Role in suite |
|---|---|
| [fawkes](https://github.com/paruff/fawkes) | ${REPO_NAME == "fawkes" && echo "$THIS_REPO_DESC" || echo "Core IDP — orchestrates the full platform stack"} |
| [uFawkesObs](https://github.com/paruff/uFawkesObs) | ${REPO_NAME == "uFawkesObs" && echo "$THIS_REPO_DESC" || echo "Observability substrate (OTel, Prometheus, Grafana, Loki, Tempo)"} |
| [uFawkesPipe](https://github.com/paruff/uFawkesPipe) | ${REPO_NAME == "uFawkesPipe" && echo "$THIS_REPO_DESC" || echo "Lightweight CI/CD (Woodpecker CI + Portainer)"} |
| [uFawkesDevX](https://github.com/paruff/uFawkesDevX) | ${REPO_NAME == "uFawkesDevX" && echo "$THIS_REPO_DESC" || echo "Developer experience (CDE, golden paths)"} |
| [uFawkesDORA](https://github.com/paruff/uFawkesDORA) | ${REPO_NAME == "uFawkesDORA" && echo "$THIS_REPO_DESC" || echo "DORA metrics dashboards and delivery benchmarks"} |
| [uFawkesSec](https://github.com/paruff/uFawkesSec) | ${REPO_NAME == "uFawkesSec" && echo "$THIS_REPO_DESC" || echo "Security posture (policy-as-code, supply chain)"} |
| [uFawkesAI](https://github.com/paruff/uFawkesAI) | ${REPO_NAME == "uFawkesAI" && echo "$THIS_REPO_DESC" || echo "AI agent and skill suite for the product lifecycle"} |
| [uFawkes.dev](https://ufawkes.dev) | ${REPO_NAME == "ufawkes.dev" && echo "$THIS_REPO_DESC" || echo "Documentation site and Dojo (five-belt learning curriculum)"} |

**Portfolio roadmap:** [fawkes/ROADMAP.md](https://github.com/paruff/fawkes/blob/main/ROADMAP.md)
**Learning:** [Fawkes Dojo](https://ufawkes.dev/dojo) — White through Black Belt curriculum
SUITE_CONTEXT

echo "✅ Suite Context section added to README.md"
echo "   Commit with: git commit -am 'docs(${REPO_NAME}): add suite context links (roadmap item 0.6)'"
```

## Batch Execution (all repos)

```bash
#!/usr/bin/env bash
# Run from parent directory containing all repos

for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI; do
  echo "=== ${repo} ==="
  cd "../${repo}" 2>/dev/null || { echo "SKIP: ${repo} not found"; continue; }
  bash .agents/skills/documentation/cross-repo-links/add-suite-context.sh "${repo}"
  # Create PR for each repo
  BRANCH="docs/add-suite-context-$(date +%Y%m%d)"
  git checkout -b "$BRANCH" 2>/dev/null
  git add README.md
  git commit -m "docs(${repo}): add suite context links (roadmap item 0.6)"
  gh pr create \
    --title "docs(${repo}): add suite context links" \
    --body "Implements roadmap item 0.6: add cross-repo links to all READMEs.

Adds the standard Suite Context section linking all 8 uFawkes* repos.

DORA capability: AI Capability 3 (AI-accessible internal data)" \
    --label "documentation,tier-1"
  cd - > /dev/null
done
```

## Output Format

```json
{
  "sub-skill": "documentation/cross-repo-links",
  "date": "YYYY-MM-DD",
  "repos_updated": ["fawkes", "uFawkesObs", "uFawkesAI"],
  "repos_already_had_links": ["uFawkesObs"],
  "repos_skipped": ["uFawkesSec"],
  "prs_created": 2,
  "roadmap_item": "0.6",
  "roadmap_item_complete": false
}
```
