---
name: documentation/ci-integration
description: "Add the docs-lint CI workflow to a repo. Catches missing files, placeholder content, broken links, and markdown lint errors on every PR. Run once per repo as part of the .gitops-templates rollout (roadmap items 0.10/0.12)."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: documentation
---

# Sub-Skill: Documentation — CI Integration

> **Load trigger:** `"load documentation/ci-integration skill"` > **DORA:** AI Capability 4 (Strong version control) + Core: Continuous Integration
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
