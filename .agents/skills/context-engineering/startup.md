---
name: context-engineering/startup
description: "Run the session startup checklist before any substantive agent work. Verifies graphify corpus currency, minimum required files, and skill list consistency. Takes under 2 minutes. Load at the start of every opencode session."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: context-engineering
---

# Sub-Skill: Context Engineering — Startup

> **Load trigger:** `"load context-engineering/startup skill"`
> **DORA:** AI Capability 3 (AI-accessible internal data)
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

### Check 6 — Graphify corpus (15 seconds, only if graphify installed)

```bash
# Only run if graphify is installed — don't error if not
if command -v graphify &> /dev/null 2>&1; then
  # [graphify-cli] status --json | jq '{last_built, files_indexed, stale}'
  echo "INFO: graphify installed — run '[graphify-cli] status' to check corpus currency"
  echo "      Replace [graphify-cli] with actual command for your graphify variant"
else
  echo "INFO: graphify not installed — context relies on file reads only"
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
  "graphify_installed": false,
  "session_status": "ready | ready-with-warnings | blocked",
  "warnings": [],
  "block_reason": null
}
```
