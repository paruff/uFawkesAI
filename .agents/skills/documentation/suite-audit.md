---
name: documentation/suite-audit
description: "Audit all 8 uFawkes* repos in one pass and produce a parity matrix. Implements roadmap item 0.6 visibility. Use quarterly or before a major suite-wide release to identify which repos are documentation-ready."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: documentation
---

# Sub-Skill: Documentation — Suite Audit

> **Load trigger:** `"load documentation/suite-audit skill"` > **DORA:** AI Capability 3 (AI-accessible internal data)
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
