---
name: context-engineering
description: "Ensure the internal context an agent needs is current, complete, and placeholder-free before each session. Define minimum AI-accessible documentation per repo. Use at session startup to verify internal context is available to AI tools. Implements DORA AI Capability 3. Includes audit for completeness and startup validation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: session
---

# Skill: context-engineering

> **Load trigger:** "load context-engineering skill" > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Ensure agents have current, complete, placeholder-free internal context before each session. This is the capability commonly called "context engineering" — connecting AI tools to internal documentation, codebases, and data sources.

This skill combines:
- **Startup validation** — runs at session start to verify context completeness
- **Audit** — comprehensive check for placeholder-free, current documentation
- **Minimum documentation standard** — defines what docs must exist for AI accessibility

## When to Use

- At the start of every agent session (via context-engineering/startup)
- Quarterly audit of internal documentation completeness
- Before any spec/design session that requires AI context
- When onboarding a new repo to uFawkesAI suite

## Sub-skills (now integrated)

### 1. Session Startup Validation (context-engineering/startup.md)

# Sub-Skill: Context Engineering — Startup

> **Load trigger:** `"load context-engineering/startup skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low
> **When to use:** First thing, every session, every repo. Non-negotiable.

## Purpose

Eliminate the "re-discover context every session" tax. A 2-minute startup check
that ensures the AI has accurate, current internal knowledge before any decisions
are made. Catches stale docs, missing files, and outdated skill references before
they cause wasted work.

## The Startup Sequence (run in this exact order)

### Check 1 — Repo identity (10 seconds)

```bash
# Confirm we're in the right repo
echo "Repo: $(basename $(git rev-parse --show-toplevel))"
echo "Branch: $(git branch --show-current)"
echo "Last commit: $(git log -1 --format='%h %s (%cr)')"
echo "Uncommitted changes: $(git status --short | wc -l | tr -d ' ') files"
```

If uncommitted changes > 5: warn — session may be entering mid-flight state.
If branch is not main and not a feature branch: ask human to confirm correct branch.

### Check 2 — Minimum corpus files (20 seconds)

```bash
MISSING=()
REQUIRED=(README.md AGENTS.md CONTRIBUTING.md AI_STANCE.md CHANGELOG.md)

for f in "${REQUIRED[@]}"; do
  [ -f "$f" ] || MISSING+=("$f")
done

# Architecture doc — either location
[ -f "ARCHITECTURE.md" ] || [ -f "docs/ARCHITECTURE.md" ] || MISSING+=("ARCHITECTURE.md")

# Test documentation
[ -f "tests/README.md" ] || [ -f "tests/TESTING.md" ] || [ -f "docs/TESTING.md" ] \
  || MISSING+=("tests/README.md")

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ All required corpus files present"
else
  echo "⚠  Missing corpus files: ${MISSING[*]}"
  echo "   Context will be incomplete. Consider running documentation/audit sub-skill."
fi
```

### Check 3 — Placeholder detection (15 seconds)

```bash
# Fail fast on obvious placeholder content that will mislead the agent
PLACEHOLDERS=$(grep -rn "\[Add contribution\|CONFIRM_VARIANT\|\[REPO_SPECIFIC\|TODO:\|Coming soon" \
  --include="*.md" . 2>/dev/null | grep -v ".git" | wc -l)

if [ "$PLACEHOLDERS" -gt 0 ]; then
  echo "⚠  $PLACEHOLDERS placeholder(s) found in markdown files"
  grep -rn "\[Add contribution\|CONFIRM_VARIANT\|\[REPO_SPECIFIC\|TODO:\|Coming soon" \
    --include="*.md" . | grep -v ".git" | head -5
  echo "   These may cause the agent to act on incomplete information."
else
  echo "✅ No placeholders detected"
fi
```

### Check 4 — AI stance currency (10 seconds)

```bash
if [ -f "AI_STANCE.md" ]; then
  LAST=$(grep "Last reviewed:" AI_STANCE.md | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "")
  if [ -n "$LAST" ]; then
    DAYS=$(python3 -c "from datetime import datetime; \
      print((datetime.utcnow() - datetime.strptime('${LAST}', '%Y-%m-%d')).days)")
    if [ "$DAYS" -gt 90 ]; then
      echo "⚠  AI_STANCE.md last reviewed ${DAYS} days ago — consider quarterly review"
    else
      echo "✅ AI_STANCE.md current (reviewed ${DAYS} days ago)"
    fi
  fi
else
  echo "❌ AI_STANCE.md missing — run ai-stance/template sub-skill before this session"
fi
```

### Check 5 — AGENTS.md skill list consistency (20 seconds)

```bash
if [ -f "AGENTS.md" ]; then
  # Extract skill names referenced in AGENTS.md
  REFERENCED=$(grep -oE '`[a-z][a-z0-9-/]+`' AGENTS.md | tr -d '`' | sort -u)

  # Check each against actual skills directory
  echo "Checking AGENTS.md skill references..."
  PENDING=()
  for skill in $REFERENCED; do
    BASE_SKILL=$(echo "$skill" | cut -d'/' -f1)
    if [ -d ".agents/skills/${BASE_SKILL}" ] || [ -d ".agents/skills/${skill}" ]; then
      : # exists
    else
      PENDING+=("$skill")
    fi
  done

  if [ ${#PENDING[@]} -eq 0 ]; then
    echo "✅ All skills referenced in AGENTS.md exist"
  else
    echo "⚠  Pending skills (referenced but not yet written): ${PENDING[*]}"
  fi
else
  echo "⚠  AGENTS.md not found — agent context will be limited"
fi
```

## Startup Report

At the end of startup, produce a one-line session readiness summary:

```
✅ Session ready: fawkes @ main | 7 required files present | AI_STANCE current | 2 pending skills
⚠  Session ready with warnings: uFawkesObs @ main | CONTRIBUTING.md is placeholder | AI_STANCE 95 days old
❌ Session blocked: uFawkesSec | AI_STANCE.md missing | run ai-stance/template first
```

**Block rule:** Only block the session (`❌`) if `AI_STANCE.md` is missing entirely.
All other findings are warnings — document them in the session log and proceed.

## Output Format

```json
{
  "sub-skill": "context-engineering/startup",
  "repo": "paruff/REPO_NAME",
  "branch": "main",
  "uncommitted_changes": 0,
  "missing_corpus_files": [],
  "placeholders_found": 0,
  "ai_stance_current": true,
  "ai_stance_days_old": 12,
  "pending_skills": ["j-curve-navigation", "dora-measurement"],
  "session_status": "ready | ready-with-warnings | blocked",
  "warnings": [],
  "block_reason": null
}
```

### 2. Context Audit (context-engineering/audit.md)

# Sub-Skill: Context Engineering — Audit

> **Load trigger:** `"load context-engineering/audit skill"` > **DORA:** AI Capability 3: AI-accessible internal data
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
DORA capability: AI Capability 3: AI-accessible internal data" \
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

## Usage

```bash
# At session start (automatic via .agents/hooks/pre-commit-agent.sh)
load context-engineering/startup skill

# Quarterly audit
load context-engineering/audit skill
```

## Enforcement

- **Startup check** runs via context-engineering/startup skill at session init
- **AI stance audit** validates clarity dimension 3 (AI-accessible internal data)
- **DORA vocabulary** validates Capability 3 references
