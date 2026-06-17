---
name: dojo-content/audit
description: "Audit existing Dojo belt modules against the 7-section gold standard. Produces a compliance matrix and prioritised fix list. Use when a module is reported broken by a learner, before publishing a new belt, or quarterly as part of Dojo maintenance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: dojo-content
---

# Sub-Skill: Dojo Content — Audit

> **Load trigger:** `"load dojo-content/audit skill"` > **DORA:** AI Capability 7 (Quality internal platforms)
> **Token cost:** Low
> **When to use:** Learner reports a broken lab, new belt release, or quarterly Dojo maintenance.

## Purpose

Verify that every published Dojo module meets the 7-section gold standard from the
parent `dojo-content` skill. A module that doesn't run on a clean environment, has
no evidence artifact, or is missing a DORA capability mapping is not ready to publish —
regardless of how well-written the prose is.

## Audit Checklist (per module)

### Section 1: Module Header

- [ ] Frontmatter present and complete: `belt`, `module`, `title`, `duration`, `dora_ai_capability`, `dora_core_capability`, `lab_stack`, `prerequisite_modules`, `lab_verified`
- [ ] `lab_verified` date is within the last 6 months
- [ ] `duration` is realistic (≤ 120 min for a single lab)

### Section 2: Why This Matters

- [ ] Present (not missing, not stub)
- [ ] Contains at least one DORA research citation with year
- [ ] States concrete consequence of not having the capability

### Section 3: What You'll Build

- [ ] States a specific, concrete deliverable (not "understand X")
- [ ] Deliverable is verifiable by the evidence artifact in Section 6

### Section 4: Prerequisites

- [ ] Lists all required prior modules by belt/number
- [ ] Lists all tools with install commands
- [ ] Time estimate present

### Section 5: The Lab

- [ ] Steps are numbered
- [ ] Every command is in a code block
- [ ] Checkpoints every 3-5 steps
- [ ] Each checkpoint states expected output AND what to do if it doesn't match
- [ ] No step requires credentials the learner won't have

### Section 6: Evidence of Completion

- [ ] Evidence artifact type defined (screenshot / URL / JSON output / file)
- [ ] Evidence artifact is produceable by following the lab steps
- [ ] Evidence is binary-verifiable (either present or not — no "looks about right")

### Section 7: What's Next

- [ ] Links to next module
- [ ] Links to the uFawkes\* repo implementing this capability in production
- [ ] One external "dig deeper" resource (link verified not broken)

## Audit Script

````bash
#!/usr/bin/env bash
# Run from the repo root
# Usage: bash .agents/skills/dojo-content/audit/run-audit.sh [module-path]

MODULE_PATH="${1}"
[ -z "$MODULE_PATH" ] && echo "Usage: $0 <path/to/module.md>" && exit 1
[ -f "$MODULE_PATH" ] || { echo "Module not found: $MODULE_PATH"; exit 1; }

echo "# Dojo Module Audit — $(basename $MODULE_PATH)"
echo "Date: $(date +%Y-%m-%d)"
echo ""

FAIL=0

# Section 1 — Frontmatter
echo "## Section 1: Module Header"
for field in belt module title duration dora_ai_capability lab_stack lab_verified; do
  if grep -q "^${field}:" "$MODULE_PATH"; then
    echo "✅ $field present"
  else
    echo "❌ $field missing from frontmatter"
    FAIL=1
  fi
done

# lab_verified recency
LAB_VERIFIED=$(grep "^lab_verified:" "$MODULE_PATH" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "")
if [ -n "$LAB_VERIFIED" ]; then
  DAYS=$(python3 -c "from datetime import datetime; \
    print((datetime.utcnow() - datetime.strptime('${LAB_VERIFIED}', '%Y-%m-%d')).days)")
  [ "$DAYS" -gt 180 ] && echo "⚠  lab_verified is ${DAYS} days old — re-verify recommended" \
                       || echo "✅ lab_verified is ${DAYS} days old"
fi
echo ""

# Section 2 — Why This Matters
echo "## Section 2: Why This Matters"
grep -q "## Why\|## Why This\|## The Problem" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
grep -qi "DORA\|dora\|state of devops" "$MODULE_PATH" \
  && echo "✅ DORA citation found" || echo "⚠  No DORA citation found"
echo ""

# Section 3 — What You'll Build
echo "## Section 3: What You'll Build"
grep -q "## What You'll Build\|## What You Will Build\|## Outcome" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
# Anti-pattern: "understand" or "learn about" suggests non-concrete deliverable
grep -iE "you will (understand|learn about|explore|get familiar)" "$MODULE_PATH" \
  && echo "⚠  Possible non-concrete deliverable — check 'What You'll Build' section"
echo ""

# Section 4 — Prerequisites
echo "## Section 4: Prerequisites"
grep -q "## Prerequisites\|## Before You Start\|## Requirements" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Section 5 — The Lab
echo "## Section 5: The Lab"
STEP_COUNT=$(grep -cE "^[0-9]+\." "$MODULE_PATH" || echo 0)
CHECKPOINT_COUNT=$(grep -ci "you should see\|expected output\|checkpoint\|verify\|✅" "$MODULE_PATH" || echo 0)
CODE_BLOCK_COUNT=$(grep -c '```' "$MODULE_PATH" || echo 0)
echo "  Steps found: ${STEP_COUNT}"
echo "  Code blocks found: $((CODE_BLOCK_COUNT / 2))"
echo "  Checkpoint signals found: ${CHECKPOINT_COUNT}"
[ "$STEP_COUNT" -gt 0 ] && echo "✅ Has numbered steps" || { echo "❌ No numbered steps"; FAIL=1; }
[ "$CODE_BLOCK_COUNT" -gt 0 ] && echo "✅ Has code blocks" || { echo "⚠  No code blocks — commands should be in code blocks"; }
[ "$CHECKPOINT_COUNT" -gt 0 ] && echo "✅ Has checkpoints" || { echo "❌ No checkpoints found"; FAIL=1; }
echo ""

# Section 6 — Evidence of Completion
echo "## Section 6: Evidence of Completion"
grep -q "## Evidence\|## Proof\|## Verification\|## You're Done" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Section 7 — What's Next
echo "## Section 7: What's Next"
grep -q "## What's Next\|## Next Steps\|## Continue" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Summary
echo "## Audit Result"
if [ $FAIL -eq 0 ]; then
  echo "✅ PASS — Module meets gold standard"
else
  echo "❌ FAIL — Module has required gaps (see above)"
fi
exit $FAIL
````

## Output Format

```json
{
  "sub-skill": "dojo-content/audit",
  "module_path": "docs/dojo/white-belt/module-01.md",
  "belt": "white",
  "module": 1,
  "lab_verified_days_ago": 45,
  "sections_present": [1, 2, 3, 4, 5, 6, 7],
  "sections_missing": [],
  "warnings": ["No DORA citation found in Why This Matters"],
  "audit_passed": true,
  "issues_to_file": 0
}
```
