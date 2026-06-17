---
name: context-engineering/audit
description: "Full corpus audit across all 8 uFawkes* repos. Produces a parity matrix showing which repos have AI-accessible context and which have gaps. Use quarterly or before a major suite-wide agent rollout."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: context-engineering
---

# Sub-Skill: Context Engineering — Audit

> **Load trigger:** `"load context-engineering/audit skill"`
> **DORA:** AI Capability 3 (AI-accessible internal data)
> **Token cost:** Low–Medium
> **When to use:** Quarterly, or before rolling out a new agent to all repos.

## Purpose

Produce a single parity matrix showing the AI-accessibility state of all 8 uFawkes\*
repos at once. Identifies which repos will give agents good context and which will
result in context-blind sessions.

## Full Suite Audit Script

```bash
#!/usr/bin/env bash
# Run from a parent directory containing all uFawkes* repos
# Adjust REPOS_DIR if needed

REPOS_DIR=".."
REPOS=(fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI "ufawkes.dev")

REQUIRED_FILES=(
  "README.md"
  "AGENTS.md"
  "CONTRIBUTING.md"
  "AI_STANCE.md"
  "CHANGELOG.md"
  "LICENSE"
)

echo "# Context Engineering Audit — $(date +%Y-%m-%d)"
echo ""
echo "## Corpus Parity Matrix"
echo ""

# Header row
printf "| %-16s |" "File"
for repo in "${REPOS[@]}"; do
  printf " %-12s |" "$repo"
done
echo ""

# Separator
printf "|%-18s|" "$(printf '%0.s-' {1..18})"
for repo in "${REPOS[@]}"; do
  printf "%-14s|" "$(printf '%0.s-' {1..14})"
done
echo ""

# Required files
for f in "${REQUIRED_FILES[@]}"; do
  printf "| %-16s |" "$f"
  for repo in "${REPOS[@]}"; do
    REPO_PATH="${REPOS_DIR}/${repo}"
    if [ -f "${REPO_PATH}/${f}" ]; then
      # Check for placeholder content
      if grep -q "\[Add contribution\|TODO:\|placeholder" "${REPO_PATH}/${f}" 2>/dev/null; then
        printf " %-12s |" "⚠ placeholder"
      else
        printf " %-12s |" "✅"
      fi
    else
      printf " %-12s |" "❌ missing"
    fi
  done
  echo ""
done

# Architecture doc (either location)
printf "| %-16s |" "ARCHITECTURE.md"
for repo in "${REPOS[@]}"; do
  REPO_PATH="${REPOS_DIR}/${repo}"
  if [ -f "${REPO_PATH}/ARCHITECTURE.md" ] || [ -f "${REPO_PATH}/docs/ARCHITECTURE.md" ]; then
    printf " %-12s |" "✅"
  else
    printf " %-12s |" "❌ missing"
  fi
done
echo ""

# Test docs
printf "| %-16s |" "tests/README.md"
for repo in "${REPOS[@]}"; do
  REPO_PATH="${REPOS_DIR}/${repo}"
  if [ -f "${REPO_PATH}/tests/README.md" ] || [ -f "${REPO_PATH}/tests/TESTING.md" ] \
     || [ -f "${REPO_PATH}/docs/TESTING.md" ]; then
    printf " %-12s |" "✅"
  else
    printf " %-12s |" "❌ missing"
  fi
done
echo ""

echo ""
echo "## Summary"
for repo in "${REPOS[@]}"; do
  REPO_PATH="${REPOS_DIR}/${repo}"
  MISSING=0
  PLACEHOLDER=0
  for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${REPO_PATH}/${f}" ]; then
      MISSING=$((MISSING + 1))
    elif grep -q "\[Add contribution\|TODO:\|placeholder" "${REPO_PATH}/${f}" 2>/dev/null; then
      PLACEHOLDER=$((PLACEHOLDER + 1))
    fi
  done

  if [ $MISSING -eq 0 ] && [ $PLACEHOLDER -eq 0 ]; then
    echo "✅ ${repo}: fully AI-accessible"
  elif [ $MISSING -gt 0 ]; then
    echo "❌ ${repo}: ${MISSING} required file(s) missing — agents will have incomplete context"
  else
    echo "⚠  ${repo}: ${PLACEHOLDER} placeholder(s) — agents may act on incomplete information"
  fi
done
```

## Scoring

Each repo receives a context-accessibility score:

| Score                             | Meaning             | Agent session quality                                                         |
| --------------------------------- | ------------------- | ----------------------------------------------------------------------------- |
| 8/8 files present, 0 placeholders | **AI-ready**        | Full context available                                                        |
| 6-7/8 files present               | **Partial context** | Agent will note gaps, proceed with caution                                    |
| 4-5/8 files present               | **Context-poor**    | High risk of context-blind decisions                                          |
| <4/8 files present                | **Context-blind**   | Do not run agentic sessions without first running `documentation/suite-audit` |

## Action Items Generated

For each repo below "AI-ready":

```bash
# Generate issues for each gap found
gh issue create \
  --repo paruff/REPO_NAME \
  --title "docs: add missing corpus files for AI-accessible context" \
  --body "## Context Engineering Audit Gap

The following required files are missing or contain placeholders:
$(for f in MISSING_FILES; do echo "- $f"; done)

This reduces agent session quality in this repo.

## Acceptance Criteria
- [ ] All required files present and not placeholders
- [ ] context-engineering/startup check passes with 0 warnings
- [ ] context-engineering/audit shows ✅ for this repo

## Reference
Skill: context-engineering/audit
DORA capability: AI Capability 3 (AI-accessible internal data)" \
  --label "documentation,tier-1"
```

## Output Format

```json
{
  "sub-skill": "context-engineering/audit",
  "date": "YYYY-MM-DD",
  "repos_audited": 8,
  "fully_accessible": ["fawkes", "uFawkesObs", "uFawkesAI"],
  "partial_context": ["uFawkesPipe", "uFawkesDevX"],
  "context_poor": ["uFawkesDORA", "uFawkesSec"],
  "context_blind": [],
  "total_gaps": 14,
  "issues_to_file": 3,
  "parity_matrix_path": "reports/context-audit-YYYY-MM-DD.md"
}
```
