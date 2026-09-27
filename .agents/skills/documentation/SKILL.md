---
name: documentation
description: "Enforce minimum documentation standard across uFawkes* repos. Implements DORA AI Capabilities 3, 6, 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: documentation

> **Load trigger:** "load documentation skill" > **DORA:** AI Capabilities 3, 6, 7
> **Token cost:** Low

## Purpose

Enforce minimum documentation standard across uFawkes* repos. Use when auditing a repo before release, onboarding a new repo to the suite, or implementing cross-repo README links. Directly supports DORA AI Capabilities 3, 6, 7.

## When to Use

- Auditing a repo before release
- Onboarding a new repo to the uFawkesAI suite
- Implementing cross-repo README links

## Sub-skills (now integrated)

### 1. Core Documentation

# Skill: Documentation

> **Load trigger:** `"load documentation skill"` > **DORA:** AI Capability 3: AI-accessible internal data + 2023 DORA finding: documentation quality
> **Token cost:** Low

## Purpose

Apply a consistent, minimum documentation standard across all 8 uFawkes\* repos.
Ensures that documentation is good enough to be AI-accessible (capability 3),
good enough to reduce onboarding friction for Dojo learners (capability 6), and
good enough to build platform trust for users evaluating fawkes (capability 7).

DORA 2023 State of DevOps: Quality documentation amplifies the positive impact of
all technical capabilities. This is not a vanity metric — it is a force multiplier.

## Minimum README Standard

Every uFawkes\* repo README must contain these sections. Use this as a checklist.
Sections marked ✅ are required for release. Sections marked ⚠ are required within
30 days of first release.

| Section              | Required | Content                                                                    |
| -------------------- | -------- | -------------------------------------------------------------------------- |
| **What This Is**     | ✅       | 2-3 sentences. What problem does this repo solve? Who is it for?           |
| **What This Is Not** | ✅       | 1-2 sentences. Explicit scope boundary prevents misuse.                    |
| **Status**           | ✅       | Current version, what works today, what's next. Update every release.      |
| **Quick Start**      | ✅       | Commands to go from clone to running in <5 min. Must actually work.        |
| **Architecture**     | ⚠        | Link to ARCHITECTURE.md or a brief component diagram.                      |
| **Testing**          | ✅       | How to run tests. Expected output. What the tests cover.                   |
| **DORA Capability**  | ⚠        | Which DORA capability this repo addresses and how.                         |
| **Contributing**     | ✅       | Link to CONTRIBUTING.md. CONTRIBUTING.md must not be a placeholder.        |
| **Suite Context**    | ✅       | Where this fits in the uFawkes portfolio. Links to fawkes and ufawkes.dev. |
| **License**          | ✅       | License type and link.                                                     |

## Cross-Repo Links Standard (Roadmap Item 0.6)

Every uFawkes\* repo README "Suite Context" section must contain:

```markdown
## Suite Context

This repo is part of the [uFawkes platform suite](https://ufawkes.dev).

| Repo                                                 | Purpose                                                   |
| ---------------------------------------------------- | --------------------------------------------------------- |
| [fawkes](https://github.com/paruff/fawkes)           | Core IDP — orchestrates the full platform                 |
| [uFawkesObs](https://github.com/paruff/uFawkesObs)   | Observability substrate (OTel, Prometheus, Grafana, Loki) |
| [uFawkesPipe](https://github.com/paruff/uFawkesPipe) | Lightweight CI/CD (Woodpecker + Portainer)                |
| [uFawkesDevX](https://github.com/paruff/uFawkesDevX) | Developer experience (CDE, golden paths)                  |
| [uFawkesDORA](https://github.com/paruff/uFawkesDORA) | DORA metrics and dashboards                               |
| [uFawkesSec](https://github.com/paruff/uFawkesSec)   | Security posture (policy-as-code)                         |
| [uFawkesAI](https://github.com/paruff/uFawkesAI)     | AI agent and skill suite                                  |
| [uFawkes.dev](https://ufawkes.dev)                   | Documentation and learning (Dojo)                         |

**Roadmap:** [fawkes/ROADMAP.md](https://github.com/paruff/fawkes/blob/main/ROADMAP.md)
```

## Required Files Beyond README

| File                                        | Required | Passes?                                    |
| ------------------------------------------- | -------- | ------------------------------------------ |
| `CHANGELOG.md`                              | ✅       | Has at least one entry; not empty          |
| `CONTRIBUTING.md`                           | ✅       | Not a placeholder; has at least 3 sections |
| `AI_STANCE.md`                              | ✅       | Present and reviewed within 90 days        |
| `AGENTS.md`                                 | ✅       | Lists current skills and agent roles       |
| `ARCHITECTURE.md` or `docs/ARCHITECTURE.md` | ✅       | Present and not a stub                     |
| `LICENSE`                                   | ✅       | Present                                    |
| `.github/CODEOWNERS`                        | ⚠        | Present (roadmap item 0.10)                |
| `tests/README.md`                           | ✅       | Explains how to run tests                  |

## Placeholder Detection

These patterns indicate a file exists but is not complete:

```bash
# Run against any repo to detect placeholders
grep -rn "\[Add " --include="*.md" . | grep -v ".git" | grep -v "node_modules"
grep -rn "TODO:" --include="*.md" . | grep -v ".git"
grep -rn "Coming soon" --include="*.md" . | grep -v ".git"
grep -rn "Under construction" --include="*.md" . | grep -v ".git"
```

Each detected placeholder is a documentation gap. File as a GitHub issue with
label `documentation`, `tier-1` if pre-release, `tier-2` if post-release.

## Documentation Currency Check (CI Integration)

Add this to any repo's CI workflow to catch stale documentation:

```yaml
# .github/workflows/docs-lint.yml
name: Documentation Lint
on: [push, pull_request]
jobs:
  docs-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check required files exist
        run: |
          for f in README.md CHANGELOG.md CONTRIBUTING.md AI_STANCE.md AGENTS.md LICENSE; do
            [ -f "$f" ] || (echo "MISSING: $f" && exit 1)
          done
          [ -f "ARCHITECTURE.md" ] || [ -f "docs/ARCHITECTURE.md" ] || \
            (echo "MISSING: ARCHITECTURE.md (check docs/ too)" && exit 1)

      - name: Check for placeholders
        run: |
          if grep -rn "\[Add contribution guidelines here\]" --include="*.md" . | grep -v ".git"; then
            echo "ERROR: CONTRIBUTING.md is still a placeholder"
            exit 1
          fi

      - name: Lint markdown
        uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: "**/*.md"
          config: ".markdownlint.json"

      - name: Check broken links
        uses: lycheeverse/lychee-action@v1
        with:
          args: --no-progress --exclude-all-private '**/*.md'
```

## Audit Output

When running a documentation audit on a repo, produce:

```json
{
  "skill": "documentation",
  "repo": "paruff/REPO_NAME",
  "audit_date": "YYYY-MM-DD",
  "release_ready": false,
  "readme": {
    "what_this_is": true,
    "what_this_is_not": true,
    "status_section": true,
    "quick_start": true,
    "testing_section": false,
    "dora_capability": false,
    "contributing_link": true,
    "suite_context": false,
    "license": true
  },
  "required_files": {
    "CHANGELOG.md": true,
    "CONTRIBUTING.md": "placeholder",
    "AI_STANCE.md": false,
    "AGENTS.md": true,
    "ARCHITECTURE.md": true,
    "LICENSE": true,
    "tests/README.md": false
  },
  "placeholders_found": 2,
  "cross_repo_links": false,
  "ci_docs_lint": false,
  "gaps": [
    { "file": "CONTRIBUTING.md", "issue": "placeholder", "tier": 1 },
    { "file": "AI_STANCE.md", "issue": "missing", "tier": 1 },
    { "file": "tests/README.md", "issue": "missing", "tier": 1 },
    { "section": "suite_context", "issue": "missing from README", "tier": 1 }
  ],
  "issues_to_file": 4
}
```

## Sub-Skills

| Sub-skill                        | Purpose                                                   |
| -------------------------------- | --------------------------------------------------------- |
| `documentation/audit`            | Full documentation audit for one repo                     |
| `documentation/suite-audit`      | Audit all 8 uFawkes\* repos and produce a parity matrix   |
| `documentation/cross-repo-links` | Add Suite Context section to all repos (roadmap item 0.6) |
| `documentation/ci-integration`   | Add docs-lint CI workflow to a repo                       |

### 2. Sub-skills

### Audit

# Sub-Skill: Documentation — Audit

> **Load trigger:** `"load documentation/audit skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low
> **When to use:** Pre-release, post-migration, or when context-engineering/audit flags gaps.

## Purpose

Produce a precise, actionable gap report for a single repo's documentation state.
Every gap has a severity, a specific remediation, and a ready-to-file issue title.
No vague "documentation needs improvement" — each item is concrete enough to complete
in one session.

## Audit Script

```bash
#!/usr/bin/env bash
# Run from the repo root

REPO=$(basename $(git rev-parse --show-toplevel))
DATE=$(date +%Y-%m-%d)
GAPS=()
CRITICAL=0
MEDIUM=0
LOW=0

echo "# Documentation Audit — ${REPO} — ${DATE}"
echo ""

# ─── REQUIRED FILES ─────────────────────────────────────────────────────────

echo "## Required Files"
echo ""

check_file() {
  local FILE=$1
  local SEVERITY=$2
  local ALT=$3  # alternative path

  if [ -f "$FILE" ] || ([ -n "$ALT" ] && [ -f "$ALT" ]); then
    # Check for placeholders
    TARGET="$FILE"
    [ -f "$FILE" ] || TARGET="$ALT"
    if grep -q "\[Add\|TODO:\|CONFIRM_VARIANT\|Coming soon\|placeholder" "$TARGET" 2>/dev/null; then
      echo "⚠  PLACEHOLDER: $FILE — contains placeholder content"
      GAPS+=("$SEVERITY|PLACEHOLDER|$FILE")
      [ "$SEVERITY" = "critical" ] && CRITICAL=$((CRITICAL+1)) || MEDIUM=$((MEDIUM+1))
    else
      echo "✅ $FILE"
    fi
  else
    echo "❌ MISSING: $FILE"
    GAPS+=("$SEVERITY|MISSING|$FILE")
    [ "$SEVERITY" = "critical" ] && CRITICAL=$((CRITICAL+1)) || MEDIUM=$((MEDIUM+1))
  fi
}

check_file "README.md" "critical"
check_file "CHANGELOG.md" "critical"
check_file "CONTRIBUTING.md" "critical"
check_file "AI_STANCE.md" "critical"
check_file "AGENTS.md" "critical"
check_file "LICENSE" "medium"
check_file "ARCHITECTURE.md" "medium" "docs/ARCHITECTURE.md"
check_file "tests/README.md" "medium" "tests/TESTING.md"

echo ""

# ─── README SECTIONS ─────────────────────────────────────────────────────────

echo "## README Sections"
echo ""

check_section() {
  local PATTERN=$1
  local LABEL=$2
  local SEVERITY=$3

  if grep -q "$PATTERN" README.md 2>/dev/null; then
    echo "✅ $LABEL"
  else
    echo "❌ MISSING: $LABEL"
    GAPS+=("$SEVERITY|MISSING_SECTION|$LABEL in README.md")
    [ "$SEVERITY" = "critical" ] && CRITICAL=$((CRITICAL+1)) || MEDIUM=$((MEDIUM+1))
  fi
}

check_section "What This Is\|## What" "What This Is" "critical"
check_section "What This Is Not\|Not a\|does not" "What This Is Not" "medium"
check_section "## Status\|Current Status\|## Current" "Status" "critical"
check_section "Quick Start\|Getting Started\|## Install" "Quick Start" "critical"
check_section "## Test\|Testing\|test suite" "Testing section" "critical"
check_section "DORA\|dora\|delivery metric" "DORA Capability" "medium"
check_section "Contributing\|CONTRIBUTING" "Contributing link" "critical"
check_section "uFawkes\|ufawkes\|fawkes suite\|Suite Context" "Suite Context" "medium"

echo ""

# ─── CROSS-REPO LINKS ────────────────────────────────────────────────────────

echo "## Cross-repo links"
echo ""

if grep -q "github.com/paruff/fawkes" README.md 2>/dev/null; then
  echo "✅ Link to fawkes present"
else
  echo "❌ MISSING: Link to fawkes repo"
  GAPS+=("medium|MISSING_LINK|Link to fawkes in README.md")
  MEDIUM=$((MEDIUM+1))
fi

if grep -q "ufawkes.dev\|uFawkes.dev" README.md 2>/dev/null; then
  echo "✅ Link to ufawkes.dev present"
else
  echo "❌ MISSING: Link to ufawkes.dev"
  GAPS+=("low|MISSING_LINK|Link to ufawkes.dev in README.md")
  LOW=$((LOW+1))
fi

if grep -q "ROADMAP" README.md 2>/dev/null; then
  echo "✅ Roadmap link present"
else
  echo "⚠  MISSING: Roadmap link"
  GAPS+=("low|MISSING_LINK|Link to ROADMAP.md in README.md")
  LOW=$((LOW+1))
fi

echo ""

# ─── SUMMARY ────────────────────────────────────────────────────────────────

echo "## Summary"
echo ""
TOTAL_GAPS=${#GAPS[@]}
echo "Total gaps: ${TOTAL_GAPS} (${CRITICAL} critical, ${MEDIUM} medium, ${LOW} low)"
echo ""

if [ $CRITICAL -eq 0 ]; then
  echo "**Release readiness: ✅ READY** (0 critical gaps)"
else
  echo "**Release readiness: ❌ NOT READY** (${CRITICAL} critical gaps must be resolved)"
fi

echo ""
echo "## GitHub Issues to File"
echo ""

for gap in "${GAPS[@]}"; do
  SEVERITY=$(echo "$gap" | cut -d'|' -f1)
  TYPE=$(echo "$gap" | cut -d'|' -f2)
  ITEM=$(echo "$gap" | cut -d'|' -f3)
  TIER="tier-2"
  [ "$SEVERITY" = "critical" ] && TIER="tier-1"
  echo "- \`docs(${REPO}): ${TYPE,,} — ${ITEM}\` [${TIER}]"
done
```

## Output Format

```json
{
  "sub-skill": "documentation/audit",
  "repo": "paruff/REPO_NAME",
  "date": "YYYY-MM-DD",
  "release_ready": false,
  "total_gaps": 5,
  "critical_gaps": 2,
  "medium_gaps": 2,
  "low_gaps": 1,
  "gaps": [
    { "severity": "critical", "type": "MISSING", "item": "AI_STANCE.md" },
    {
      "severity": "critical",
      "type": "MISSING_SECTION",
      "item": "Testing section in README.md"
    },
    { "severity": "medium", "type": "PLACEHOLDER", "item": "CONTRIBUTING.md" },
    {
      "severity": "medium",
      "type": "MISSING_SECTION",
      "item": "DORA Capability in README.md"
    },
    {
      "severity": "low",
      "type": "MISSING_LINK",
      "item": "Link to ROADMAP.md in README.md"
    }
  ],
  "issues_to_file": 5
}
```

### Ci Integration

# Sub-Skill: Documentation — CI Integration

> **Load trigger:** `"load documentation/ci-integration skill"` > **DORA:** AI Capability 4: Strong version control practices + Core: Continuous Integration
> **Token cost:** Low
> **When to use:** When adding the standard GitHub pipeline to a repo (roadmap item 0.10/0.12).

## Purpose

Make documentation gaps fail CI rather than be discovered during release. A PR that
deletes the "Testing" section from README.md should fail the same way a failing unit
test fails. This sub-skill adds that enforcement.

Aligns with roadmap items 0.10 (`create .gitops-templates/ with pre-commit, CI, etc.`)
and 0.12 (`migrate all repos to GitOps standards`).

## Files to Create

### 1. `.github/workflows/docs-lint.yml`

```yaml
name: Documentation Lint

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  required-files:
    name: Required files present
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check required files exist and are not placeholders
        run: |
          FAIL=0

          # Required files
          for f in README.md CHANGELOG.md CONTRIBUTING.md LICENSE; do
            if [ ! -f "$f" ]; then
              echo "❌ MISSING: $f"
              FAIL=1
            fi
          done

          # AI_STANCE.md — required for uFawkesAI suite repos
          if [ ! -f "AI_STANCE.md" ]; then
            echo "❌ MISSING: AI_STANCE.md"
            FAIL=1
          fi

          # AGENTS.md — required if .agents/ exists
          if [ -d ".agents" ] && [ ! -f "AGENTS.md" ]; then
            echo "❌ MISSING: AGENTS.md (required when .agents/ exists)"
            FAIL=1
          fi

          # Architecture doc — either location
          if [ ! -f "ARCHITECTURE.md" ] && [ ! -f "docs/ARCHITECTURE.md" ]; then
            echo "⚠  WARNING: ARCHITECTURE.md not found (check docs/ too)"
            # Warning only — not blocking. Set FAIL=1 when ready to enforce.
          fi

          # Placeholder check
          if grep -rn "\[Add contribution guidelines here\]" --include="*.md" . | grep -v ".git"; then
            echo "❌ CONTRIBUTING.md is still a placeholder"
            FAIL=1
          fi

          if grep -rn "CONFIRM_VARIANT" --include="*.md" . | grep -v ".git"; then
            echo "❌ Unresolved CONFIRM_VARIANT placeholder in markdown files"
            FAIL=1
          fi

          # README required sections
          for section in "## Status" "## Quick Start\|Getting Started\|## Install" "## Test"; do
            if ! grep -qE "$section" README.md; then
              echo "⚠  WARNING: README.md may be missing section: $section"
              # Warning only
            fi
          done

          exit $FAIL

  markdown-lint:
    name: Markdown lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: "**/*.md"
          config: ".markdownlint.json"

  link-check:
    name: Check links
    runs-on: ubuntu-latest
    # Run on push to main only — link checks on PRs can be flaky with draft links
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - uses: lycheeverse/lychee-action@v2
        with:
          args: >
            --no-progress
            --exclude-all-private
            --exclude 'localhost'
            --exclude '0\.0\.0\.0'
            --exclude 'example\.com'
            '**/*.md'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 2. `.markdownlint.json`

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false,
  "MD004": { "style": "dash" },
  "MD007": { "indent": 2 },
  "MD024": { "siblings_only": true },
  "MD029": false,
  "MD036": false
}
```

Rules disabled:

- `MD013`: line length (too strict for tables and code blocks)
- `MD033`: inline HTML (needed for some GitHub-rendered markdown)
- `MD041`: first line heading (READMEs often start with badges)
- `MD029`: ordered list item prefix (allow 1. 1. 1. style)
- `MD036`: no emphasis as heading (too strict for skill files)

## Installation Script

```bash
#!/usr/bin/env bash
# Run from the repo root

mkdir -p .github/workflows

# Only create if it doesn't exist — don't overwrite customized versions
if [ -f ".github/workflows/docs-lint.yml" ]; then
  echo "⚠  .github/workflows/docs-lint.yml already exists — review manually"
else
  # Write the workflow file (paste from template above)
  echo "✅ Created .github/workflows/docs-lint.yml"
fi

if [ -f ".markdownlint.json" ]; then
  echo "⚠  .markdownlint.json already exists — review manually"
else
  # Write the markdownlint config (paste from template above)
  echo "✅ Created .markdownlint.json"
fi

# Add to pre-commit if pre-commit is configured
if [ -f ".pre-commit-config.yaml" ]; then
  if ! grep -q "markdownlint" .pre-commit-config.yaml; then
    cat >> .pre-commit-config.yaml << 'PRECOMMIT'

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.39.0
    hooks:
      - id: markdownlint
        args: ["--config", ".markdownlint.json"]
PRECOMMIT
    echo "✅ Added markdownlint to .pre-commit-config.yaml"
  fi
fi

# Commit
git add .github/workflows/docs-lint.yml .markdownlint.json .pre-commit-config.yaml 2>/dev/null
git commit -m "ci: add docs-lint workflow and markdownlint config"
echo "✅ Committed docs-lint CI"
```

## First-Run Triage

The first time docs-lint runs on a repo with existing docs, it will likely fail.
Triage strategy:

1. Run locally first: `npx markdownlint-cli2 "**/*.md"`
2. Fix any line-level errors (usually heading syntax, list formatting)
3. For structural gaps (missing sections) — file as tier-1 issues, don't fix in the same PR
4. Merge the CI workflow PR even if the first run shows warnings — address them in follow-up issues

## Output Format

```json
{
  "sub-skill": "documentation/ci-integration",
  "repo": "paruff/REPO_NAME",
  "workflow_created": true,
  "markdownlint_config_created": true,
  "pre_commit_updated": true,
  "first_run_expected_failures": [
    "CONTRIBUTING.md placeholder",
    "missing ARCHITECTURE.md"
  ],
  "issues_to_file": 2,
  "roadmap_items": ["0.10", "0.12"]
}
```

### Cross Repo Links

# Sub-Skill: Documentation — Cross-Repo Links

> **Load trigger:** `"load documentation/cross-repo-links skill"` > **DORA:** AI Capability 3: AI-accessible internal data
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

DORA capability: AI Capability 3: AI-accessible internal data" \
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

### Suite Audit

# Sub-Skill: Documentation — Suite Audit

> **Load trigger:** `"load documentation/suite-audit skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low
> **When to use:** Quarterly, or before adding a new repo to the portfolio.

## Purpose

A single-pass audit across all 8 repos that produces a parity matrix — one view of
which repos meet the minimum documentation standard and which don't. This is the
portfolio-level view; use `documentation/audit` for per-repo deep dives.

## Suite Parity Matrix Script

```bash
#!/usr/bin/env bash
# Run from parent directory containing all uFawkes* repos

REPOS=(fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI "ufawkes.dev")
CHECKS=("README.md" "CHANGELOG.md" "CONTRIBUTING.md" "AI_STANCE.md" "AGENTS.md" "ARCHITECTURE.md")

echo "# Documentation Suite Audit — $(date +%Y-%m-%d)"
echo ""
echo "## Parity Matrix"
echo ""

# Print header
printf "| %-14s |" "Check"
for repo in "${REPOS[@]}"; do printf " %-11s |" "${repo:0:11}"; done
echo ""
printf "|%-16s|" "$(printf '%.0s-' {1..16})"
for repo in "${REPOS[@]}"; do printf "%-13s|" "$(printf '%.0s-' {1..13})"; done
echo ""

# Check each file across all repos
for check in "${CHECKS[@]}"; do
  printf "| %-14s |" "${check:0:14}"
  for repo in "${REPOS[@]}"; do
    PATH_TO_CHECK="../${repo}/${check}"
    ALT_PATH="../${repo}/docs/${check}"

    if [ -f "$PATH_TO_CHECK" ] || [ -f "$ALT_PATH" ]; then
      TARGET="$PATH_TO_CHECK"
      [ -f "$PATH_TO_CHECK" ] || TARGET="$ALT_PATH"
      if grep -q "\[Add\|TODO:\|placeholder\|CONFIRM_VARIANT" "$TARGET" 2>/dev/null; then
        printf " %-11s |" "⚠ stub"
      else
        printf " %-11s |" "✅"
      fi
    else
      printf " %-11s |" "❌"
    fi
  done
  echo ""
done

# Suite context links
printf "| %-14s |" "Suite links"
for repo in "${REPOS[@]}"; do
  if grep -q "paruff/fawkes\|ufawkes.dev" "../${repo}/README.md" 2>/dev/null; then
    printf " %-11s |" "✅"
  else
    printf " %-11s |" "❌"
  fi
done
echo ""

echo ""
echo "## Repo Scores"
echo ""

TOTAL_CHECKS=$(( ${#CHECKS[@]} + 1 ))  # +1 for suite links check

for repo in "${REPOS[@]}"; do
  SCORE=0
  for check in "${CHECKS[@]}"; do
    PATH_TO_CHECK="../${repo}/${check}"
    ALT_PATH="../${repo}/docs/${check}"
    if [ -f "$PATH_TO_CHECK" ] || [ -f "$ALT_PATH" ]; then
      CONTENT_CHECK="$PATH_TO_CHECK"
      [ -f "$PATH_TO_CHECK" ] || CONTENT_CHECK="$ALT_PATH"
      if ! grep -q "\[Add\|TODO:\|placeholder" "$CONTENT_CHECK" 2>/dev/null; then
        SCORE=$((SCORE+1))
      fi
    fi
  done
  grep -q "paruff/fawkes\|ufawkes.dev" "../${repo}/README.md" 2>/dev/null && SCORE=$((SCORE+1))

  PCT=$(( SCORE * 100 / TOTAL_CHECKS ))
  if [ $PCT -ge 90 ]; then
    STATUS="✅ AI-ready"
  elif [ $PCT -ge 70 ]; then
    STATUS="⚠  Partial"
  else
    STATUS="❌ Context-poor"
  fi
  echo "  ${repo}: ${SCORE}/${TOTAL_CHECKS} (${PCT}%) — ${STATUS}"
done

echo ""
echo "## Priority Actions"
echo ""
echo "Repos needing immediate attention (< 70% score):"
for repo in "${REPOS[@]}"; do
  SCORE=0
  for check in "${CHECKS[@]}"; do
    [ -f "../${repo}/${check}" ] || [ -f "../${repo}/docs/${check}" ] && SCORE=$((SCORE+1))
  done
  PCT=$(( SCORE * 100 / TOTAL_CHECKS ))
  if [ $PCT -lt 70 ]; then
    echo "  - ${repo}: run documentation/audit for detailed gap report"
    echo "    gh issue create --repo paruff/${repo} --title \"docs: documentation audit gap — ${repo}\" --label documentation,tier-1"
  fi
done
```

## Reading the Matrix

| Symbol | Meaning                                      |
| ------ | -------------------------------------------- |
| ✅     | File exists and has substantive content      |
| ⚠ stub | File exists but contains placeholder content |
| ❌     | File is missing entirely                     |

**Action rule:** Any ❌ in a required file (README, CHANGELOG, CONTRIBUTING, AI_STANCE, AGENTS) is a tier-1 issue. Any ⚠ stub is tier-2. Any ❌ in an optional file (ARCHITECTURE, suite links) is tier-2.

## Output Format

```json
{
  "sub-skill": "documentation/suite-audit",
  "date": "YYYY-MM-DD",
  "repos_audited": 8,
  "repo_scores": {
    "fawkes": { "score": 7, "total": 7, "pct": 100, "status": "ai-ready" },
    "uFawkesObs": { "score": 7, "total": 7, "pct": 100, "status": "ai-ready" },
    "uFawkesPipe": {
      "score": 4,
      "total": 7,
      "pct": 57,
      "status": "context-poor"
    },
    "uFawkesDevX": {
      "score": 3,
      "total": 7,
      "pct": 43,
      "status": "context-poor"
    },
    "uFawkesDORA": {
      "score": 2,
      "total": 7,
      "pct": 29,
      "status": "context-poor"
    },
    "uFawkesSec": {
      "score": 2,
      "total": 7,
      "pct": 29,
      "status": "context-poor"
    },
    "uFawkesAI": { "score": 6, "total": 7, "pct": 86, "status": "partial" },
    "ufawkes.dev": { "score": 5, "total": 7, "pct": 71, "status": "partial" }
  },
  "ai_ready_count": 2,
  "partial_count": 2,
  "context_poor_count": 4,
  "priority_issues_to_file": 4
}
```

## Usage

```bash
# Audit documentation
load documentation/audit skill

# CI integration for docs
load documentation/ci-integration skill

# Cross-repo links
load documentation/cross-repo-links skill

# Suite audit
load documentation/suite-audit skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 3, 6, 7 references
- **AI stance audit** validates relevant clarity dimensions
