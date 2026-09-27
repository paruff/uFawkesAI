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
