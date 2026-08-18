---
name: ai-stance/diff
description: "Compare AI_STANCE.md files across two or more uFawkes* repos to identify inconsistencies in tool permissions, prohibited uses, and guardrail conditions. Use during quarterly cross-repo consistency check or when adopting a new tool suite-wide."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: ai-stance
---

# Sub-Skill: AI Stance — Diff

> **Load trigger:** `"load ai-stance/diff skill"` > **DORA:** AI Capability 1 (Clear and communicated AI stance)
> **Token cost:** Low
> **When to use:** Quarterly cross-repo check, or when adopting a new tool suite-wide.

## Purpose

A tool listed as Prohibited in one repo but Allowed in another is a policy gap —
it means contributors switching between repos get conflicting signals, and agents
operating across repos may behave inconsistently. This sub-skill surfaces those
gaps systematically.

## What Counts as an Inconsistency

| Type                   | Example                                                      | Severity    |
| ---------------------- | ------------------------------------------------------------ | ----------- |
| **Bucket conflict**    | Tool X is Prohibited in fawkes but Allowed in uFawkesAI      | 🔴 Critical |
| **Missing tool**       | opencode listed in 7 repos but not in uFawkesSec             | 🟡 Medium   |
| **Guardrail mismatch** | Same tool, different guardrail conditions in different repos | 🟡 Medium   |
| **Review date skew**   | Some repos reviewed 5 days ago, one reviewed 200 days ago    | 🟢 Low      |
| **Version skew**       | <model-id> in 6 repos, older model in 2 repos         | 🟡 Medium   |

## Comparison Protocol

```bash
#!/usr/bin/env bash
# Run from a parent directory containing all uFawkes* repos as subdirectories
# Or adjust REPOS array to absolute paths

REPOS=(
  "fawkes"
  "uFawkesObs"
  "uFawkesPipe"
  "uFawkesDevX"
  "uFawkesDORA"
  "uFawkesSec"
  "uFawkesAI"
  "ufawkes.dev"
)

echo "=== AI_STANCE.md presence check ==="
for repo in "${REPOS[@]}"; do
  if [ -f "../${repo}/AI_STANCE.md" ]; then
    LAST=$(grep "Last reviewed:" "../${repo}/AI_STANCE.md" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "unknown")
    echo "✅ ${repo}: present (last reviewed: ${LAST})"
  else
    echo "❌ ${repo}: AI_STANCE.md MISSING"
  fi
done

echo ""
echo "=== Permitted tools comparison ==="
for tool in opencode graphify ponytail "claude" "GitHub Copilot"; do
  echo "--- ${tool} ---"
  for repo in "${REPOS[@]}"; do
    STANCE="../${repo}/AI_STANCE.md"
    [ -f "$STANCE" ] || continue
    if grep -qi "prohibited" "$STANCE" | grep -qi "${tool}"; then
      echo "  🔴 ${repo}: PROHIBITED"
    elif grep -qi "${tool}" "$STANCE"; then
      BUCKET=$(grep -B5 "${tool}" "$STANCE" | grep "###" | tail -1 | sed 's/### //')
      echo "  ✅ ${repo}: ${BUCKET}"
    else
      echo "  ⚠  ${repo}: NOT LISTED"
    fi
  done
done

echo ""
echo "=== Prohibited items — check for cross-repo gaps ==="
echo "Items prohibited in any repo:"
for repo in "${REPOS[@]}"; do
  STANCE="../${repo}/AI_STANCE.md"
  [ -f "$STANCE" ] || continue
  awk '/### Prohibited/,/### Permitted/' "$STANCE" | grep "^-" | sed "s/^/  [${repo}] /"
done | sort | uniq
```

## Diff Output Structure

```markdown
## AI Stance Cross-Repo Diff — [DATE]

### Repos audited: N/8

Missing AI_STANCE.md: [list repos]

### Critical inconsistencies (bucket conflicts)

| Tool / Use | Repo A bucket | Repo B bucket | Resolution                                    |
| ---------- | ------------- | ------------- | --------------------------------------------- |
| [tool]     | Prohibited    | Allowed       | Align to Prohibited — file issues in [repo B] |

### Medium inconsistencies

| Issue                        | Repos affected | Recommended resolution          |
| ---------------------------- | -------------- | ------------------------------- |
| [tool] version skew          | [repos]        | Update all to the current model |
| Missing from permitted tools | [repos]        | Add [tool] to permitted list    |

### Review date status

| Repo       | Last reviewed | Days ago | Status     |
| ---------- | ------------- | -------- | ---------- |
| fawkes     | YYYY-MM-DD    | N        | ✅ Current |
| uFawkesSec | YYYY-MM-DD    | 200      | 🔴 Overdue |

### Actions required

1. [Priority 1 — critical inconsistency fix with gh issue create command]
2. [Priority 2 — missing stance fix with gh issue create command]
3. [Priority 3 — review overdue fix]
```

## Resolution Protocol

For each critical inconsistency found, the more restrictive bucket wins by default.
A tool that's Prohibited anywhere should be Prohibited everywhere unless there is
an explicit, documented reason why one repo has a different risk profile.

```bash
# File issues for each inconsistency found
gh issue create \
  --repo paruff/REPO_NAME \
  --title "ai-policy: align AI_STANCE.md with suite-wide policy — [INCONSISTENCY]" \
  --body "## Inconsistency found during cross-repo diff

**Tool/Use:** [name]
**This repo:** [current bucket]
**Other repos:** [their bucket]
**Recommended resolution:** [align to X because Y]

## Action
Update AI_STANCE.md in this repo to match the suite-wide policy.
Reference: ai-stance/diff run on [DATE]" \
  --label "ai-policy,tier-1"
```

## Output Format

```json
{
  "sub-skill": "ai-stance/diff",
  "date": "YYYY-MM-DD",
  "repos_checked": 8,
  "repos_missing_stance": ["uFawkesSec"],
  "critical_inconsistencies": [],
  "medium_inconsistencies": [
    {
      "type": "version_skew",
      "tool": "claude",
      "repos_current": ["fawkes", "uFawkesObs", "uFawkesAI"],
      "repos_stale": ["uFawkesPipe"],
      "recommended": "Update uFawkesPipe to the current model"
    }
  ],
  "review_overdue_repos": [],
  "issues_to_file": 2,
  "suite_policy_consistent": false
}
```
