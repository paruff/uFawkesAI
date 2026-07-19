---
name: dojo-content/lab-verify
description: "Run the lab verification protocol for an existing Dojo module — reproduce it on a clean environment, time each step, record actual vs stated duration, and update lab_verified date. Required before publishing any new or updated module."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: dojo-content
---

# Sub-Skill: Dojo Content — Lab Verify

> **Load trigger:** `"load dojo-content/lab-verify skill"` > **DORA:** AI Capability 7 (Quality internal platforms) + Core: Test automation
> **Token cost:** Low
> **When to use:** Before publishing any new or updated module. Required — not optional.

## Purpose

A module that doesn't work on a clean environment is worse than no module —
it erodes trust and causes learners to abandon the Dojo. This sub-skill is the
quality gate. Every module must pass lab verification before `lab_verified` is set.

**The rule:** If the lab fails verification, fix it before setting `lab_verified`.
No exceptions. No "it mostly works." The learner will hit the same failure you hit.

## Verification Environment Requirements

The lab must be verified from a state that approximates a learner's first encounter:

| Requirement                                       | Why                                                   |
| ------------------------------------------------- | ----------------------------------------------------- |
| Clean directory (no prior runs of this lab)       | Eliminates "works because cache exists" failures      |
| Only prerequisite tools installed (nothing extra) | Learner may not have additional tools                 |
| No existing config files from previous sessions   | Real first-run experience                             |
| Recorded in a new terminal with timing            | Produces the evidence artifact for the module         |
| Same OS as stated in Prerequisites                | Mac ARM, Linux x86, etc. — matters for Docker/compose |

Fastest way to achieve this: a new Docker container, a fresh VM snapshot, or
a new Coder/VS Code Server workspace from a base image.

## Verification Protocol

### Step 1 — Pre-verification setup (5 min)

```bash
# Record start time
VERIFY_START=$(date +%s)
VERIFY_DATE=$(date +%Y-%m-%d)

# Confirm clean environment
echo "=== Environment check ==="
echo "OS: $(uname -a)"
echo "Docker: $(docker --version 2>/dev/null || echo 'not installed')"
echo "Compose: $(docker compose version 2>/dev/null || echo 'not installed')"
echo "git: $(git --version)"
# Add other prerequisite checks based on the module

# Confirm no leftover state
docker ps -a | grep -i "MODULE_NAME" && echo "⚠ Found existing containers — remove before verifying"
```

### Step 2 — Follow the module exactly as written (no shortcuts)

Do not:

- Skip steps because "obviously that will work"
- Use credentials or config you happen to have
- Fix things inline without noting them

Do:

- Time each step with `time` or manually
- Record every command that fails — even if you know the fix
- Record every place where you needed to look something up externally

### Step 3 — Record the verification run

```bash
# Create a verification log
cat > /tmp/lab-verify-log.md << EOF
# Lab Verification Log — [MODULE TITLE]
Date: ${VERIFY_DATE}
Verifier: paruff
Environment: [OS, relevant tool versions]

## Step-by-step timing

| Step | Expected time | Actual time | Result | Notes |
|---|---|---|---|---|
| 1 | X min | Y min | ✅/❌ | |
| 2 | X min | Y min | ✅/❌ | |

## Issues found
[List every failure, confusion, or external lookup required]

## Evidence artifact produced
[Description of what was produced — screenshot taken, URL accessed, JSON output]

## Total time
Expected: [stated in module] min
Actual: [measured] min
Variance: [Actual - Expected] min ([percentage]% over/under)
EOF
```

### Step 4 — Evaluate pass/fail

| Outcome                                                    | Action                                                                    |
| ---------------------------------------------------------- | ------------------------------------------------------------------------- |
| All steps complete, evidence produced, no external lookups | ✅ PASS — set `lab_verified` date                                         |
| Steps complete but required one external lookup            | ⚠ CONDITIONAL — update module to include the missing info, then re-verify |
| Any step failed                                            | ❌ FAIL — fix the module, do not set `lab_verified` until re-verified     |
| Actual time > 120% of stated time                          | ❌ FAIL — update time estimate and re-verify                              |

### Step 5 — Update the module

If PASS:

```bash
# Update lab_verified date in frontmatter
sed -i "s/^lab_verified:.*/lab_verified: ${VERIFY_DATE}/" MODULE_PATH

# If time estimate changed, update duration
# sed -i "s/^duration:.*/duration: ACTUAL_MINUTES min/" MODULE_PATH

git add MODULE_PATH
git commit -m "docs(dojo): verify lab $(basename MODULE_PATH) — lab_verified ${VERIFY_DATE}"
```

If FAIL: fix issues, then run verification again from Step 1.

## Evidence Artifact Record

After a successful verification, add this block to the module's Section 6:

```markdown
## Evidence of Completion

To confirm you've completed this lab successfully:

**Expected output:**
[Paste actual output from your verification run — not what you think it should be]

**Screenshot target:**
[Describe exactly what should be visible — which URL, which panel, which metric]

**Verification command:**
\`\`\`bash

# Run this to self-check your completion

[command that produces binary pass/fail output]
\`\`\`
```

## Output Format

```json
{
  "sub-skill": "dojo-content/lab-verify",
  "module": "docs/dojo/white-belt/module-01.md",
  "verification_date": "YYYY-MM-DD",
  "environment": "Ubuntu 24.04, Docker 26.1, Compose v2.27",
  "result": "pass | fail | conditional",
  "steps_passed": 12,
  "steps_failed": 0,
  "external_lookups_required": 0,
  "expected_duration_minutes": 60,
  "actual_duration_minutes": 58,
  "evidence_artifact_produced": true,
  "issues_found": [],
  "module_updated": true,
  "lab_verified_date_set": "YYYY-MM-DD"
}
```
