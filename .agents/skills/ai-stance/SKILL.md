---
name: ai-stance
description: "Generate and maintain AI_STANCE.md for any uFawkes* repo. Use when onboarding a repo to the uFawkesAI suite, when reviewing AI policy currency, or when a new AI tool is being adopted. Implements DORA AI Capability 1. Handles review triggers, three-bucket update process, socialization checklist, and cross-repo consistency."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: quarterly
---

# Skill: ai-stance

> **Load trigger:** "load ai-stance skill" > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low

## Purpose

Generate and maintain AI_STANCE.md for any uFawkes* repo. Use when onboarding a repo to the uFawkesAI suite, when reviewing AI policy currency, or when a new AI tool is being adopted. Implements DORA AI Capability 1.

This skill combines:
- Stance generation from template
- Quarterly audit for completeness, currency, and four-dimension coverage
- Diff detection for policy drift
- Template for new repos
- Policy lifecycle management (review triggers, socialization, cross-repo consistency)

## When to Use

- Onboarding a new repo to the uFawkesAI suite
- Quarterly AI policy review
- After adopting a new AI tool
- Before any release (policy currency check)
- When a Prohibited-item violation is reported

## Sub-skills (now integrated)

### 1. Stance Generation (template.md)

# Sub-Skill: AI Stance — Template

> **Load trigger:** `"load ai-stance/template skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low
> **When to use:** Repo has no `AI_STANCE.md`. Run once per repo.

## Purpose

Generate a complete, populated `AI_STANCE.md` for a new repo. Asks four questions,
fills the three-bucket framework, and writes the file. Total time: under 15 minutes.

## Inputs Required

Before generating, confirm:

| Input                                      | Where to find it                             | Required? |
| ------------------------------------------ | -------------------------------------------- | --------- |
| Repo name                                  | Current working directory / git remote       | ✅        |
| Primary persona using this repo            | Persona reference table in `discovery` skill | ✅        |
| Any repo-specific prohibited uses          | Human judgment call                          | ✅        |
| Any tools NOT in the suite defaults        | Human input                                  | Optional  |
| Compliance requirements (SOC2, GDPR, etc.) | Project context                              | Optional  |

## Generation Steps

### Step 1 — Confirm suite defaults apply

Check whether the repo needs any deviation from the suite-wide defaults in the
parent `ai-stance` skill:

```
Suite defaults cover:
✅ opencode, ponytail, <current Claude model>
✅ Standard prohibited list (PII, secrets, bypass pre-commit/branch protection)
✅ Standard guardrails (human review before merge, session logging)

Does this repo need additions? Common repo-specific additions:
- uFawkesObs: "Prohibited: AI-generated Prometheus alerting rules without human review
  (alerts trigger pager — false positives have real cost)"
- uFawkesSec: "Prohibited: AI-generated OPA/Kyverno policies without security review"
- uFawkes.dev: "Permitted-with-guardrails: AI-generated Dojo content must include
  disclosure to learners that AI assisted in authoring"
```

### Step 2 — Write the file

```bash
# Confirm repo name
REPO=$(basename $(git rev-parse --show-toplevel))
TODAY=$(date +%Y-%m-%d)
NEXT_REVIEW=$(date -d "+90 days" +%Y-%m-%d 2>/dev/null || date -v+90d +%Y-%m-%d)

cat > AI_STANCE.md << 'STANCE'
# AI Stance — REPO_PLACEHOLDER

> Last reviewed: TODAY_PLACEHOLDER
> Next review due: NEXT_PLACEHOLDER (quarterly)
> Owner: paruff
> Suite: uFawkesAI

## Expectation of Use

AI-assisted development is expected in this repo. We use AI tools to clear bottlenecks
in the product lifecycle — not to replace human judgment on architecture, security,
and user research decisions. All AI assistance is logged via opencode session history.

## Organizational Support

- Permitted tools: listed below
- Skill suite: uFawkesAI `.agents/skills/` — load relevant skills before each session
- Context corpus: maintained via context-engineering skill (load at session start)
- Questions or policy concerns: file a GitHub issue with label `ai-policy`
- Policy reviews: quarterly — see ai-policy-lifecycle skill

## Permitted Tools

| Tool | Model / version | Scope |
|---|---|---|
| opencode | latest stable | Primary agentic development tool |
| Claude | <current Claude model — check anthropic.com/models> | Skill authoring, code review, content generation |
| ponytail | latest stable | YAGNI enforcement in all agent sessions |
| GitHub Copilot | current | IDE code completion |

## Three-Bucket Classification

### Prohibited
- Sending PII, credentials, or proprietary infrastructure configs to public AI models
- Committing AI-generated code without pre-commit hooks passing
- Bypassing branch protection rules on AI guidance
- AI-generated security policy or compliance docs without qualified human review
- [REPO_SPECIFIC_PROHIBITED — add any repo-specific items here or delete this line]

### Permitted with Guardrails

| Use | Guardrail |
|---|---|
| AI-generated code merged to main | Human review required; at least one test covering the change |
| AI-assisted spec / design documents | discovery-brief.md must exist first |
| Agent sessions modifying infrastructure | j-curve-navigation pre-flight check must pass |
| AI-generated release notes | Human review before publishing |
| AI-generated content in Dojo modules | Disclose to learners that AI assisted in authoring |
| opencode sessions in this repo | Load AGENTS.md and relevant skills at session start |

### Allowed
- AI-assisted code completion for any file not in the Prohibited scope
- AI-generated first drafts of blog posts, dev.to articles, LinkedIn posts
- AI-assisted GitHub issue triage and labeling
- AI-generated test stubs (human completes and verifies)
- Asking AI tools to explain existing code or documentation

## Role Applicability

This stance applies to: **human contributors AND AI agents** (opencode sessions,
GitHub Actions opencode workflow, any automated agent invocation in this repo).

Agents must:
1. Load `ai-stance` skill and verify this document exists before beginning work
2. Log the session via opencode session history
3. Flag any action that would fall into the Prohibited bucket and halt — do not
   proceed without explicit human authorization for prohibited actions
STANCE

# Substitute placeholders
sed -i "s/REPO_PLACEHOLDER/${REPO}/g" AI_STANCE.md
sed -i "s/TODAY_PLACEHOLDER/${TODAY}/g" AI_STANCE.md
sed -i "s/NEXT_PLACEHOLDER/${NEXT_REVIEW}/g" AI_STANCE.md

echo "✅ AI_STANCE.md generated for ${REPO}"
echo "⚠  Review and update:"
echo "   - [REPO_SPECIFIC_PROHIBITED]: Add repo-specific prohibitions or delete the line"
```

### Step 3 — Verify with audit sub-skill

After generating, immediately run the audit sub-skill to confirm all four clarity
dimensions are present:

```
Load trigger: "load ai-stance/audit skill"
```

## Output Format

```json
{
  "sub-skill": "ai-stance/template",
  "repo": "paruff/REPO_NAME",
  "file_created": "AI_STANCE.md",
  "placeholders_remaining": ["CONFIRM_VARIANT"],
  "repo_specific_items_needed": true,
  "audit_recommended": true
}
```

### 2. Stance Audit (audit.md)

# Sub-Skill: AI Stance — Audit

> **Load trigger:** `"load ai-stance/audit skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low
> **When to use:** Quarterly review, after tool adoption, or before release.

## Purpose

Verify that an existing `AI_STANCE.md` is complete, current, and covers all four
DORA-required clarity dimensions. Produces a structured gap report with specific
remediation steps, not just a pass/fail.

## Audit Checklist

### Dimension 1 — Expectation of use

- [ ] Document states whether AI use is expected / encouraged / optional / discouraged
- [ ] One sentence explains _why_ (not just _that_)
- [ ] Applies to both human contributors and AI agents

### Dimension 2 — Organizational support

- [ ] Permitted tools section present and complete
- [ ] Each tool has a named version or model (not "latest LLM")
- [ ] Skill suite reference present (where to find usage conventions)
- [ ] Feedback mechanism named (how to raise policy concerns)

### Dimension 3 — Permitted tools

- [ ] All actively-used tools are listed
- [ ] No EOL or deprecated tools remain in the Permitted list
- [ ] <model-id in AI_STANCE.md> is current (check against provider's current model list)
- [ ] No tool is in Allowed that should have guardrails given current usage patterns

### Dimension 4 — Role applicability

- [ ] States whether stance applies to humans, agents, or both
- [ ] Agent-specific obligations defined (load ai-stance, log session, halt on Prohibited)

### Currency checks

- [ ] `Last reviewed` date present
- [ ] `Next review due` date present and not past
- [ ] No `[PLACEHOLDER]` strings remaining anywhere in the file

### Three-bucket completeness

- [ ] Prohibited section: at least 3 items (sparse Prohibited = policy not thought through)
- [ ] Permitted-with-guardrails: each item has explicit, specific guardrail condition
- [ ] Allowed: items are genuinely low-risk (no item that should require guardrails)
- [ ] No "it depends" without specifying what it depends on

## Automated Checks

```bash
# Run against any repo
STANCE="AI_STANCE.md"

# Checks print FAIL: but must also exit nonzero, or the FAIL is just text.
# A failure counter is used rather than 'set -e' on purpose: almost every check
# below is a 'grep ... && echo FAIL || echo PASS' chain, and under 'set -e' the
# *passing* case (grep finds nothing, chain returns 1) would abort the run.
FAILURES=0
fail() { echo "FAIL: $*"; FAILURES=$((FAILURES + 1)); }
pass() { echo "PASS: $*"; }
warn() { echo "WARN: $*"; }

# Hard-exit before any check: with the file missing, every 'grep && echo FAIL ||
# echo PASS' chain takes the FAIL branch by accident, and the placeholder check
# reports "PASS: no placeholders" for a file that does not exist.
if [ ! -f "$STANCE" ]; then
  echo "FAIL: $STANCE missing — cannot audit"
  exit 1
fi

echo "=== Currency check ==="
grep -q "Last reviewed:" "$STANCE" && pass "last reviewed date present" || fail "last reviewed date missing"
grep -q "Next review due:" "$STANCE" && pass "next review date present" || fail "next review date missing"

echo "=== Placeholder check ==="
if grep -n "PLACEHOLDER\|CONFIRM_VARIANT\|\[Add\|TODO" "$STANCE"; then
  fail "placeholders remain"
else
  pass "no placeholders"
fi

echo "=== Three-bucket presence ==="
grep -q "### Prohibited" "$STANCE" && pass "Prohibited section present" || fail "Prohibited section missing"
grep -q "### Permitted with Guardrails" "$STANCE" && pass "Guardrails section present" || fail "Guardrails section missing"
grep -q "### Allowed" "$STANCE" && pass "Allowed section present" || fail "Allowed section missing"

echo "=== Role applicability ==="
# Was 'grep -qi "agent\|human" "$STANCE" | grep -qi "applies"': the first grep's
# stdout was piped into the second, which tests the matched lines rather than
# the file, so the check was neither true nor false — it was noise.
if grep -qi "applies" "$STANCE" && grep -qiE "agent|human" "$STANCE"; then
  pass "role applicability stated"
else
  warn "verify role applicability section"
fi

echo "=== Tool currency ==="
grep -Eo "claude-[a-z0-9-]+" "$STANCE" | sort -u | sed 's/^/INFO: model id to verify: /'

echo "=== Overdue review ==="
LAST_REVIEW=$(grep "Last reviewed:" "$STANCE" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")
if [ -n "$LAST_REVIEW" ]; then
  # utcnow() is deprecated in Python 3.12+; use an explicit UTC tz. A review date
  # in the future yields a negative age and used to report "PASS: review current".
  python3 - "$LAST_REVIEW" <<'PY'
import sys
from datetime import datetime, timezone

days = (datetime.now(timezone.utc).date()
        - datetime.strptime(sys.argv[1], "%Y-%m-%d").date()).days
print(f"INFO: {days} days since last review")
if days < 0:
    print("FAIL: last-reviewed date is in the future")
    sys.exit(1)
if days > 90:
    print("FAIL: review overdue (>90 days)")
    sys.exit(1)
print("PASS: review current")
PY
  [ $? -eq 0 ] || fail "review currency check failed"
else
  fail "no parseable 'Last reviewed:' date"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: PASS — no gaps"
  exit 0
fi
echo "RESULT: FAIL — $FAILURES gap(s)"
exit 1
```

## Gap Report Format

For each failed check, produce:

```markdown
## AI_STANCE.md Gap Report — [REPO_NAME] — [DATE]

### Critical gaps (block release)

- [ ] [gap description] → [specific remediation, e.g., "Add the missing tool to the Permitted Tools table"]

### Non-critical gaps (fix within 30 days)

- [ ] [gap description] → [specific remediation]

### Informational

- [observation that's not a gap but worth noting]

### Summary

- Gaps found: N critical, M non-critical
- Review overdue: Yes/No (X days since last review)
- Recommended action: [Immediate fix | Schedule review | No action needed]
```

## Output Format

```json
{
  "sub-skill": "ai-stance/audit",
  "repo": "paruff/REPO_NAME",
  "stance_exists": true,
  "last_reviewed": "YYYY-MM-DD",
  "days_since_review": 45,
  "review_overdue": false,
  "critical_gaps": [],
  "non_critical_gaps": [],
  "four_dimensions_present": {
    "expectation_of_use": true,
    "organizational_support": true,
    "permitted_tools": true,
    "role_applicability": true
  },
  "placeholders_remaining": 0,
  "audit_passed": true
}
```

### 3. Stance Diff / Drift Detection (diff.md)

# Sub-Skill: AI Stance — Diff

> **Load trigger:** `"load ai-stance/diff skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
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
# Run from INSIDE one of the uFawkes* repos: the paths below are "../<repo>",
# i.e. siblings of the current working directory. Running from the parent
# directory itself looks for "../<repo>" one level too high and reports every
# repo MISSING. Or replace the "../" prefix with absolute paths in REPOS.

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
for tool in opencode ponytail "claude" "GitHub Copilot"; do
  echo "--- ${tool} ---"
  for repo in "${REPOS[@]}"; do
    STANCE="../${repo}/AI_STANCE.md"
    [ -f "$STANCE" ] || continue
    # Resolve which '### <Bucket>' heading the tool sits under, then compare that
    # bucket. This replaces 'grep -qi "prohibited" "$STANCE" | grep -qi "$tool"',
    # which piped the first grep's stdout into the second: it searched the
    # matched lines for the tool name instead of the file, so the branch could
    # never mean what it claimed.
    BUCKET=$(grep -B5 -i -- "${tool}" "$STANCE" | grep '^###' | tail -1 | sed 's/^### //')
    if [ -z "$BUCKET" ]; then
      echo "  ⚠  ${repo}: NOT LISTED"
    elif printf '%s' "$BUCKET" | grep -qi "prohibited"; then
      echo "  🔴 ${repo}: PROHIBITED"
    else
      echo "  ✅ ${repo}: ${BUCKET}"
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

### 4. Policy Lifecycle (ai-policy-lifecycle)

# AI Policy Lifecycle Rules

> **Form:** rule, not procedure. These constraints apply at all times; the
> quarterly review below is how they get re-checked, not when they take effect.
> **DORA:** AI Capability 1: Clear and communicated AI stance

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

## Usage

```bash
# Generate initial stance from template
load ai-stance skill

# Quarterly audit
load ai-stance/audit skill

# Check for policy drift
load ai-stance/diff skill

# Full lifecycle review
load ai-policy-lifecycle skill
```

## Enforcement

- **AI stance audit** runs in pre-commit via `scripts/check-ai-stance.sh`
- **DORA vocabulary** validates Capability 1 references
- **Agent dispatch** validates Capability 1 references
