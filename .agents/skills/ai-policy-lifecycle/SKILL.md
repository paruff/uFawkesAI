---
name: ai-policy-lifecycle
description: "Maintain AI_STANCE.md as a living document. Use quarterly or when a new AI tool is adopted. Handles review triggers, the three-bucket update process, socialization checklist, and cross-repo consistency. Companion to ai-stance skill."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: quarterly
---

# AI Policy Lifecycle Rules

> **Form:** rule, not procedure. These constraints apply at all times; the
> quarterly review below is how they get re-checked, not when they take effect.
> **DORA:** AI Capability 1 (Clear and communicated AI stance)

- Every `uFawkes*` repo maintains an `AI_STANCE.md` stating its AI stance.
- `AI_STANCE.md` must carry all three buckets: Allowed, Permitted with
  Guardrails, and Prohibited. A tool with no bucket is unstated, not allowed.
- `AI_STANCE.md` carries a `Last reviewed:` date and is re-reviewed **quarterly**.
- A newly adopted AI tool triggers an out-of-cycle review, not a wait for the
  next quarter.
- The stance states whether the policy applies to agents, humans, or both.
- A stance change is socialised before it is treated as enforced: written down,
  guardrail proposed, evidence attached.
- Stances stay consistent across repos; a repo that contradicts the suite
  stance is a gap to resolve, not a local override.
- `.agents/skills/ai-stance/audit.md` is the executable check for these rules.
  Run it rather than eyeballing `AI_STANCE.md`.

## Quarterly review process

> **Load trigger:** `"load ai-policy-lifecycle skill"`

## Purpose

`ai-stance` creates `AI_STANCE.md`. This skill keeps it alive.

A static AI policy document becomes a liability within one tool adoption cycle.
The DORA AI Capabilities Model v2025.1 explicitly warns against treating AI policy
as a one-time artifact. This skill defines the quarterly review cadence, the process
for updating the three buckets when circumstances change, and the socialization
pattern that ensures every contributor (human and agent) encounters the updated policy.

## Review Triggers

| Trigger                                | Action                                                         | Priority |
| -------------------------------------- | -------------------------------------------------------------- | -------- |
| Quarterly calendar (every 90 days)     | Full review — run all five steps                               | Medium   |
| New AI tool adopted                    | Update Permitted tools table + re-assess Prohibited/Guardrails | High     |
| Security incident involving AI tool    | Immediate review of relevant bucket                            | Critical |
| New contributor onboarded              | Verify they've read AI_STANCE.md                               | Low      |
| DORA AI Capabilities research updated  | Check if new capability changes the stance framing             | Low      |
| GitHub issue labeled `ai-policy` filed | Triage and incorporate if valid                                | Medium   |

## Five-Step Review Process

### Step 1 — Freshness check (5 min)

```bash
# Check last review date
grep "Last reviewed:" AI_STANCE.md
# Check days elapsed
python3 -c "
from datetime import datetime
last = datetime.strptime('YYYY-MM-DD', '%Y-%m-%d')
print(f'{(datetime.utcnow() - last).days} days since last review')
"
# Check for open ai-policy issues
gh issue list --repo paruff/REPO_NAME --label "ai-policy" --state open
```

### Step 2 — Tool audit (10 min)

For each tool in the Permitted tools table:

- Is it still actively maintained? (check for archived repo, EOL notice)
- Has the version/model changed? (<model-id> → newer model? (check provider's current model list))
- Have new capabilities been added that change its risk profile?
- Are there new tools in active use that aren't in the table?

Flag any tool that:

- Is in the Prohibited list and no longer needs to be (unblock opportunity)
- Is in the Allowed list but should now have guardrails (risk increased)
- Is in Permitted-with-guardrails but guardrails are no longer sufficient (promote to Prohibited)
- Is being used but not listed (immediate addition required)

### Step 3 — Three-bucket update (10 min)

For each proposed change, apply the decision rule:

| Change type                                   | Process                                                          |
| --------------------------------------------- | ---------------------------------------------------------------- |
| Moving Prohibited → Permitted-with-guardrails | Requires explicit rationale + defined guardrail + human sign-off |
| Moving Allowed → Permitted-with-guardrails    | Document the new risk; add guardrail; no sign-off required       |
| Moving any bucket → Prohibited                | Document the specific incident or risk driver; immediate effect  |
| Adding new tool to Permitted-with-guardrails  | Define all guardrail conditions before adding                    |
| Removing a tool                               | Note why (deprecated, replaced, security concern)                |

### Step 4 — Socialization checklist (5 min)

After any update, ensure the policy reaches all consumers:

```markdown
Socialization checklist for AI_STANCE.md v[NEW_VERSION]:

- [ ] `Last reviewed` date updated in AI_STANCE.md
- [ ] `Next review due` date set (90 days from today)
- [ ] AGENTS.md updated if permitted tool list changed
- [ ] README.md "AI Tools" section updated if present
- [ ] GitHub Release or pinned Discussion note posted (for significant changes)
- [ ] Cross-repo check: do other uFawkes\* repos need the same update? (see Step 5)
- [ ] Commit: `docs(ai-policy): update AI_STANCE.md - [one-line summary of change]`
```

### Step 5 — Cross-repo consistency check (5 min)

The fawkes suite has 8 repos. A tool added to the Prohibited list in one repo should
be prohibited in all of them. A new tool adopted in uFawkesAI should be assessed for
all other repos.

```bash
# Check for inconsistencies across repos (requires all repos cloned locally)
for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI ufawkes.dev; do
  if [ -f "../${repo}/AI_STANCE.md" ]; then
    echo "=== ${repo} ==="
    grep -A 3 "Last reviewed:" "../${repo}/AI_STANCE.md"
    grep "ponytail\|opencode\|claude" "../${repo}/AI_STANCE.md" | head -5
  else
    echo "=== ${repo}: AI_STANCE.md MISSING ==="
  fi
done
```

File a GitHub issue for any repo missing `AI_STANCE.md` (label: `ai-policy`, `tier-1`).
File a GitHub issue for any inconsistency in tool classification across repos.

## Feedback Loop

The `ai-policy` GitHub issue label is the mechanism for any contributor
(including agents) to propose a policy change:

```bash
# Agent filing an ai-policy issue
gh issue create \
  --repo paruff/REPO_NAME \
  --title "ai-policy: [tool name] should be added to Permitted-with-guardrails" \
  --body "## Proposed change
[Tool]: [current bucket] → [proposed bucket]

## Rationale
[Why this change improves the stance]

## Proposed guardrail (if moving to Permitted-with-guardrails)
[Specific condition that must be met]

## Evidence
[Incident, adoption pattern, or research that motivates this]" \
  --label "ai-policy"
```

## Output Format

```json
{
  "skill": "ai-policy-lifecycle",
  "repo": "paruff/REPO_NAME",
  "last_reviewed": "YYYY-MM-DD",
  "days_since_review": 45,
  "review_overdue": false,
  "next_review_due": "YYYY-MM-DD",
  "changes_made": [
    {
      "type": "tool_updated",
      "tool": "claude",
      "change": "Model updated to <model-id>",
      "bucket": "permitted-with-guardrails"
    }
  ],
  "tools_audited": 5,
  "tools_flagged": 0,
  "repos_missing_stance": [],
  "cross_repo_inconsistencies": [],
  "socialization_complete": true,
  "issues_filed": []
}
```
