# Metrics

> Run monthly: `npm run metrics && npm run token-audit --save`
> DORA 2025 basis: rework rate is the earliest signal that AI output quality is degrading.

---

## The Seven Metrics

### 1. Rework Rate (DORA 2025 Core)

**Formula:** `(lines substantially changed within 14 days of authoring / total lines authored) × 100`

**Targets:** < 10% ✅ | 10–20% ⚠️ | > 20% 🛑 Stop features, fix `AGENTS.md` first

**Measurement:**

```bash
npm run metrics
# Or manually:
git log --since="28 days ago" --format="%H %ae %s" | head -50
```

**What counts as rework:** lines reverted, substantially rewritten, or rolled back within 14 days of the original commit. Rebases and force-pushes are excluded.

---

### 2. PR Revision Rate

**Formula:** `(PRs requiring more than 2 review cycles / total PRs merged) × 100`

**Targets:** < 25% ✅ | 25–40% ⚠️ | > 40% 🛑

**Measurement:** `npm run metrics`

**If high:** Check issue template quality — are specs clear enough for agents to implement correctly first time?

---

### 3. CI Cycle Time

**Formula:** `median time from PR open to CI green`

**Targets:** < 4 min ✅ | 4–10 min ⚠️ | > 10 min 🛑

**Measurement:** GitHub Actions → workflow run durations

---

### 4. Review Turnaround

**Formula:** `median time from PR open to first human review`

**Targets:** < 24h ✅ | 24–72h ⚠️ | > 72h 🛑

**DORA finding:** "Teams with shorter code review times have 50% better delivery performance."

---

### 5. Failed Deployment Recovery Time (FDRT)

**Formula:** `time from failed deployment detection to service restoration`

**Targets:** < 1h ✅ | 1–4h ⚠️ | > 4h 🛑

**Measurement:** Manual — record in incidents log when deployments fail

---

### 6. Reliability (Change Failure Rate Trend)

**Formula:** `(deployments causing incidents / total deployments) × 100, tracked over 90 days`

**Targets:** declining trend ✅ | flat ⚠️ | increasing 🛑

**Note:** DORA 2025 quasi-metric — track as a trend, not an absolute.

---

### 7. AI Credit Burn Rate _(New — June 2026)_

**Formula:** `total Copilot AI Credits consumed / merged PRs in the period`

**Targets:** Decreasing trend ✅ | Flat ⚠️ | Increasing 🛑

**Measurement:** GitHub billing dashboard → Copilot usage → export to CSV

**What increasing burn rate signals:**

- `AGENTS.md` growing too large (run `npm run token-audit`)
- Developers using Agent Mode for questions (see `docs/MODEL_ROUTING_GUIDE.md`)
- Vague prompts causing multi-turn retry loops
- Wrong model selection (frontier-tier model for tasks a mid-tier model handles fine)

**Correlation insight:** If rework rate and credit burn rate both increase together,
the root cause is almost always `AGENTS.md` quality or team prompt discipline.
Fix `AGENTS.md` first.

---

## Monthly Review Ritual (15 minutes)

```bash
# 1. Run metrics
npm run metrics

# 2. Run token audit and save
npm run token-audit --save

# 3. Review the dashboard
open https://github.com/settings/billing/copilot_usage   # individual
# or: github.com/orgs/[ORG]/settings/copilot/seat_management (org admin)

# 4. Record below
```

---

## Monthly Records

| Month   | Rework % | PR Revision % | CI Time | Review Time | Credit Burn/PR | Notes          |
| ------- | -------- | ------------- | ------- | ----------- | -------------- | -------------- |
| 2026-06 | —        | —             | —       | —           | —              | Baseline month |

---

## Archetype Review

Run `docs/TEAM_ARCHETYPE.md` self-assessment quarterly.
Current archetype: [PLACEHOLDER]
Last assessed: [PLACEHOLDER]

Do NOT use elite/high/medium/low tier labels. Use DORA 2025 archetype names.

---

## If Rework Rate > 10%

1. Stop adding features
2. Run `npm run token-audit` — is `AGENTS.md` too large?
3. Review last 10 PRs — what patterns caused rework?
4. Update `AGENTS.md` accordingly (keep it lean — move details to skills)
5. Review `docs/MODEL_ROUTING_GUIDE.md` with the team
6. Resume features only after one week below 10%

## If Credit Burn Rate is Increasing

1. Run `npm run token-audit` — check always-on context size
2. Review team's Agent Mode usage patterns
3. Run a 30-min model routing workshop using `docs/MODEL_ROUTING_GUIDE.md`
4. Check `.github/copilot-budget.md` — are admin controls configured?
