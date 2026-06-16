# Agent Metrics

> Track which agents and skills actually fire, what they produce, and whether findings are actionable.
> Run: `bash scripts/agent-metrics.sh --save`

---

## Why This Matters

Without telemetry, every skill and agent is equally important — which means none of them are.
This file records real invocation data so you can:

- Archive skills that never fire
- Consolidate overlapping skills
- Identify agents with high noise-to-signal ratios
- Track blocker density over time (are agents getting more or less critical?)

---

## Latest Snapshot

<!-- AGENT_METRICS_AUTO:START -->
_No data yet. Run `bash scripts/agent-metrics.sh --save` after agents have logged invocations._
<!-- AGENT_METRICS_AUTO:END -->

---

## Interpretation Guide

| Signal | What It Means | Action |
|--------|--------------|--------|
| Skill loaded 0 times in 90 days | Dead weight in the skill registry | Archive it |
| Finding actionability < 40% | Agent produces too much noise | Tighten the agent's protocol |
| Manual review burden > 30% | Findings require too much human judgment | Add more specific rules to the agent |
| Blocker density increasing | Agents are getting more critical — or quality is dropping | Investigate root cause |
| Single agent > 50% of all invocations | Other agents may be underutilized or routing is wrong | Review agent routing in AGENTS.md |

---

## Logging Protocol

Every agent writes a JSON log entry after completing its task:

```json
{
  "agent": "agent-name",
  "session_id": "unique-id",
  "timestamp": "2026-06-15T10:30:00Z",
  "skills_loaded": ["domain/skill-name"],
  "findings": [
    {
      "severity": "HIGH",
      "category": "skill-category",
      "summary": "Finding description",
      "actionable": true,
      "manual_review_needed": false
    }
  ],
  "decision": "PASS",
  "blockers": 0
}
```

Logs are appended to `.agents/logs/YYYY-MM-DD.jsonl` (one JSON object per line).

---

## References

- Schema: `.agents/schema/skill-invocation-log.json`
- Aggregation script: `scripts/agent-metrics.sh`
- Logs directory: `.agents/logs/`
