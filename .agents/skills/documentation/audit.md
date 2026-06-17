---
name: documentation/audit
description: "Full documentation audit for one repo against the minimum standard defined in the documentation skill. Produces a gap report with severity ratings and ready-to-file GitHub issue titles. Use before any release or when a repo is flagged as context-poor by context-engineering/audit."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: documentation
---

# Sub-Skill: Documentation — Audit

> **Load trigger:** `"load documentation/audit skill"` > **DORA:** AI Capability 3 (AI-accessible internal data)
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
