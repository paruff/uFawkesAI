# Runbooks — [PROJECT NAME]

> Operational procedures for the most critical scenarios.
> Every procedure has been tested. If a step fails, update the runbook.

---

## Runbook 1 — Emergency Rollback

> DORA 2025 (INSTAB-01): "Rollback capability is a prerequisite for safe AI-assisted delivery.
> Teams must be able to revert any deploy within minutes."

**Trigger:** Error rate spikes > 3× baseline within 30 minutes of a deploy.

**Steps:**

```bash
# 1. Identify the bad commit
git log --oneline main | head -5

# 2. Revert the merge commit
git revert -m 1 <merge-commit-sha>
git push origin main

# [PLACEHOLDER — add your deploy step, e.g.:]
# 3. For Expo OTA: Roll back the update channel
expo publish:history --channel production
expo publish:rollback --channel production --sdk-version <version>

# 4. Verify error rate normalising in error monitoring (Sentry / etc.)
```

**After rollback:**
1. File a bug issue linking the error monitoring report
2. Root cause analysis: Was it a Copilot pattern failure? If yes → update `AGENTS.md`.
3. Add a regression test before re-deploying

---

## Runbook 2 — Disable a Feature Remotely

> DORA 2025 (INSTAB-01): Feature flags allow disabling a feature without a new deploy.

**Trigger:** A newly shipped feature is causing user issues but a full rollback would affect other features.

[PLACEHOLDER — replace with your feature flag mechanism. Example for Firestore remote flags:]

```
1. Go to [Firebase Console / feature flag service]
2. Navigate to: config/featureFlags document
3. Set the problematic flag to false
4. Change takes effect on next app foreground — no new deploy needed
5. File a bug issue to track the root cause and re-enable timeline
```

**Feature flag registry:** See `src/config/featureFlags.ts`

---

## Runbook 3 — Change Failure Response

**Trigger:** A deploy causes a user-visible bug, crash, or data issue.

```
1. Assess severity:
   - P1 (data loss or security): Emergency rollback immediately (Runbook 1)
   - P2 (feature broken): Disable via feature flag (Runbook 2) if possible
   - P3 (cosmetic/minor): File issue, fix in next sprint

2. Communicate: [PLACEHOLDER — how you notify users/stakeholders]

3. Root cause analysis:
   □ Was it AI-generated code that wasn't adequately reviewed? → Update AGENTS.md
   □ Was it a missing test case? → Add regression test before re-deploying
   □ Was it an unclear spec? → PM updates issue template
   □ Was it an architecture violation that slipped through? → Update ESLint rules

4. Update docs/METRICS.md with the change failure event
5. Close the incident when the fix is deployed and verified
```

---

## Runbook 4 — Weekly Metrics Review

**Cadence:** Last Friday of each month (15 minutes)

```bash
npm run metrics
```

Review the output:

| Metric | If above target... |
|---|---|
| Rework rate 10–20% | Review recent Copilot output patterns; update AGENTS.md if drift observed |
| Rework rate > 20% | Stop features. Fix instructions. Run prompt library review. |
| Change failure rate > 5% | Review last 3 incidents. Improve test coverage in affected areas. |
| CI time > 4 min | File a performance issue for CI optimisation |
| PR revision rate > 25% | Review issue template quality — specs may be too vague |

Update `docs/METRICS.md` monthly log.

---

## Runbook 5 — Documentation Freshness Check

**Cadence:** Monthly, or when a documentation freshness CI comment fires

```
For each changed service or utility file:
□ Does docs/API_SURFACE.md reflect all current public functions?
  → Run: @docs-agent [files changed] — update API_SURFACE.md
□ Does docs/CHANGE_IMPACT_MAP.md reflect new cross-file dependencies?
  → Update the map manually or with @docs-agent
□ Does docs/KNOWN_LIMITATIONS.md have any limitations that are now fixed?
  → Remove them and note in PR
□ Does docs/ARCHITECTURE.md still accurately describe the layer structure?
  → Update if new patterns were introduced
```

---

## Runbook 6 — Monthly DevEx Review

**Cadence:** Last Friday of each month (5 minutes)

Score each dimension 1–5 in `docs/DEVEX_LOG.md`:

| Dimension | Score (1–5) |
|---|---|
| Flow — how often do I reach flow state? | |
| Feedback Speed — how fast does the system respond? | |
| Cognitive Load — how hard is it to navigate the code? | |
| AI Trust — how often do I accept Copilot output? | |
| Tooling Friction — how often does tooling block me? | |

**Triggers:**
- Any dimension < 3 for two consecutive months → file an improvement issue
- AI Trust < 3 → review AGENTS.md and PROMPT_LIBRARY.md
- Cognitive Load ≥ 4 → run a Value Stream Mapping exercise
