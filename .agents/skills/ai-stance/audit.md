---
name: ai-stance/audit
description: "Review an existing AI_STANCE.md for completeness, currency, and four-dimension coverage. Use quarterly, after tool changes, or before any release. Produces a structured gap report."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: ai-stance
---

# Sub-Skill: AI Stance — Audit

> **Load trigger:** `"load ai-stance/audit skill"` > **DORA:** AI Capability 1 (Clear and communicated AI stance)
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
- [ ] graphify variant confirmed (not `[CONFIRM_VARIANT]` placeholder)
- [ ] claude-sonnet-4-6 is current model (check against Anthropic's current model list)
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

echo "=== Currency check ==="
[ -f "$STANCE" ] || echo "FAIL: AI_STANCE.md missing"
grep -q "Last reviewed:" "$STANCE" && echo "PASS: last reviewed date present" || echo "FAIL: last reviewed date missing"
grep -q "Next review due:" "$STANCE" && echo "PASS: next review date present" || echo "FAIL: next review date missing"

echo "=== Placeholder check ==="
grep -n "PLACEHOLDER\|CONFIRM_VARIANT\|\[Add\|TODO" "$STANCE" && echo "FAIL: placeholders remain" || echo "PASS: no placeholders"

echo "=== Three-bucket presence ==="
grep -q "### Prohibited" "$STANCE" && echo "PASS: Prohibited section present" || echo "FAIL: Prohibited section missing"
grep -q "### Permitted with Guardrails" "$STANCE" && echo "PASS: Guardrails section present" || echo "FAIL: Guardrails section missing"
grep -q "### Allowed" "$STANCE" && echo "PASS: Allowed section present" || echo "FAIL: Allowed section missing"

echo "=== Role applicability ==="
grep -qi "agent\|human" "$STANCE" | grep -qi "applies" && echo "PASS: role applicability stated" || echo "WARN: verify role applicability section"

echo "=== Tool currency ==="
grep "claude-sonnet-4-6" "$STANCE" && echo "INFO: check if claude-sonnet-4-6 is still current at anthropic.com/models"
grep "CONFIRM_VARIANT" "$STANCE" && echo "FAIL: graphify variant not confirmed"

echo "=== Overdue review ==="
LAST_REVIEW=$(grep "Last reviewed:" "$STANCE" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")
if [ -n "$LAST_REVIEW" ]; then
  python3 -c "
from datetime import datetime
last = datetime.strptime('${LAST_REVIEW}', '%Y-%m-%d')
days = (datetime.utcnow() - last).days
print(f'INFO: {days} days since last review')
if days > 90: print('FAIL: review overdue (>90 days)')
else: print('PASS: review current')
"
fi
```

## Gap Report Format

For each failed check, produce:

```markdown
## AI_STANCE.md Gap Report — [REPO_NAME] — [DATE]

### Critical gaps (block release)

- [ ] [gap description] → [specific remediation, e.g., "Add graphify variant to Permitted Tools table"]

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
  "non_critical_gaps": ["graphify variant not confirmed in Permitted Tools"],
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
