# Delivery Metrics Baseline

This page is the authoritative reference for the DORA-style metrics in this repository. It gives the metric names, source citations, formulas, thresholds, and the commands that produce the underlying numbers. Use it as the single source of truth before interpreting `npm run metrics` output or writing a monthly review.

## Quick reference

| Metric | DORA source | Data source | Green | Amber | Red |
| --- | --- | --- | --- | --- | --- |
| Rework rate | DORA 2025 AI Capabilities / State of AI-assisted Software Development | local git history (`git log --numstat`) | < 10% | 10–20% | > 20% |
| PR revision rate | DORA 2025 review flow guidance | merge history in git | < 25% | 25–40% | > 40% |
| CI cycle time | DORA 2025 delivery performance | GitHub Actions workflow runs | < 4 min | 4–10 min | > 10 min |
| Review turnaround | DORA 2025 review speed | GitHub PR timestamps | < 24h | 24–72h | > 72h |
| Failed deployment recovery time | DORA 2025 recovery / reliability | incident or deployment records | < 1h | 1–4h | > 4h |
| Reliability / change fail rate | DORA 2025 delivery metrics | deployment and incident records | improving trend | flat | rising trend |

> The repo currently runs a local git heuristic for rework and PR revision rate. GitHub API-backed versions can replace the local proxy once a deployment/CI data source is wired in.

---

## 1. Rework rate

- DORA source: DORA 2025, _State of AI-assisted Software Development_ / AI Capabilities model — rework rate is the first signal that AI-assisted output quality is degrading.
- Formula: `(lines changed again within 14 days of the original change ÷ total lines authored in the same period) × 100`
- Data source: local git history; use `git log --numstat --since="14 days ago"` and count lines that are rewritten within the rework window.
- Target: green < 10%, amber 10–20%, red > 20%.

### Calculation

Use the command below to generate the inputs:

```bash
git -C . log --since="14 days ago" --reverse --pretty=format:'@@@ %ct' --numstat --
```

The local script that powers `npm run metrics` interprets this as:

- `total` = summation of added + deleted lines in the window
- `rework` = lines in files that were already seen and then changed again within 14 days
- `rework rate` = `rework / total × 100`

This is intentionally a heuristic. It tells you whether output is being retraced in a short window, not whether every line was individually reviewed by a human.

### Edge cases and caveats

- Rebases and force-pushes hide prior history, so the value is best interpreted as a local proxy, not a legal record of all edits.
- Squash and rebase merge flows flatten the branch history; the script therefore treats merge-based PR revision rate as a best-effort proxy.
- If a file is touched again within 14 days, the churn is counted as rework only when it is still in the window. Once the window passes, it no longer counts.

### Worked example

Suppose the repo had 4,000 changed lines in the last 14 days and 280 of those lines were touched again within the same rework window.

- Rework rate = `280 / 4,000 × 100 = 7.0%`
- Result: green, because 7.0% < 10%

The repo's heuristic uses the same approach in `scripts/weekly-metrics.sh`.

---

## 2. PR revision rate

- DORA source: DORA 2025 review-flow guidance; this is the percentage of merged PRs that need real revision work rather than a clean first pass.
- Formula: `(PRs that require additional revision after merge intent or after the branch is merged ÷ total merged PRs) × 100`
- Data source: git merge history; the repo currently approximates this by counting merge commits whose branch contains multiple commits.
- Target: green < 25%, amber 25–40%, red > 40%.

### Worked example

If 20 PRs merged in the window and 4 of them clearly had revision work after the initial PR flow, then:

- PR revision rate = `4 / 20 × 100 = 20%`
- Result: green, because 20% < 25%

This is a proxy measurement because squash/rebase merges are flattened in git history and therefore are not directly counted by the local heuristic.

---

## 3. CI cycle time

- DORA source: DORA 2025 delivery-performance research; high cycle time is a sign that the feedback loop is slowing the team.
- Formula: median (or p50) time from PR open to CI green
- Data source: GitHub Actions workflow run durations; use `gh run list --json createdAt,updatedAt,conclusion` or the workflow API.
- Target: green < 4 minutes, amber 4–10 minutes, red > 10 minutes.

### Worked example

If the median CI runtime for the last 30 PRs is 3.4 minutes:

- Result: green, because 3.4 min < 4 min

A long CI queue usually signals the need to reduce test scope, better parallelism, or smaller PRs.

---

## 4. Review turnaround

- DORA source: DORA 2025 review-speed findings.
- Formula: median time from PR open to the first human review comment or approval
- Data source: pull request timestamps from GitHub
- Target: green < 24 hours, amber 24–72 hours, red > 72 hours.

### Worked example

If the median time to first human review is 18 hours:

- Result: green, because 18h < 24h

This metric explains whether the review bottleneck is slowing delivery, even when CI is healthy.

---

## 5. Failed deployment recovery time (FDRT)

- DORA source: DORA 2025 reliability and recovery guidance
- Formula: time from failed deployment detection until service is restored
- Data source: incident or deployment records; for a local repo, record the incident in a team log with timestamps.
- Target: green < 1 hour, amber 1–4 hours, red > 4 hours.

### Worked example

If a deployment failed at 10:15 and the service was restored by 11:00:

- Recovery time = 45 minutes
- Result: green, because 45 min < 1 hour

This metric matters because a slow recovery time often hurts user trust more than a single failed deployment.

---

## 6. Reliability / change fail rate

- DORA source: DORA 2025 software delivery metrics
- Formula: `(deployments causing incidents or rollback ÷ total deployments) × 100`, tracked over 90 days
- Data source: deployment and incident logs
- Target: green = trend is improving; amber = flat; red = rising trend or repeated failures

### Worked example

If 12 of 180 deployments caused incidents in the last quarter:

- Change fail rate = `12 / 180 × 100 = 6.7%`
- Result: amber if the trend is flat or red if it is rising; green only when the rate is decreasing over time.

This is a trend metric rather than a one-off pass/fail ceiling.

---

## How to run your first metrics report

Copy and paste the following commands from the repo root:

```bash
# 1) Verify you are in the repo root
pwd
ls docs

# 2) Produce the local git-based snapshot
npm run metrics -- --days=14

# 3) Inspect the generated block in the metrics doc
sed -n '/<!-- METRICS_AUTO:START -->/,/<!-- METRICS_AUTO:END -->/p' docs/METRICS.md

# 4) If GitHub Actions data is available, export CI timings
gh run list --limit 20 --json name,createdAt,updatedAt,conclusion,status
```

If you are starting from zero, use the 14-day window first. It keeps the report small enough to review, and it aligns with the same rework window used in `scripts/weekly-metrics.sh`.

---

## Monthly review ritual (spaced repetition)

This repository follows the Dojo-style practice of spaced repetition: review the same metrics on a fixed cadence so the signal becomes familiar before you change behavior.

Set a 15-minute review at the start of each month.

1. Run `npm run metrics -- --days=14`.
2. Compare each metric against the green/amber/red targets above.
3. Write one sentence for each red/amber metric: what changed, why it matters, and one action to take next.
4. Schedule the follow-up action for the next review window rather than trying to fix everything immediately.
5. Update the notes in the running history below.

Repeat the same review for three consecutive months before deciding whether the metric is structural or just a temporary spike.

---

## Running log

| Month | Rework % | PR Revision % | CI Time | Review Turnaround | Recovery Time | Reliability | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| YYYY-MM | — | — | — | — | — | — | Baseline month |

<!-- METRICS_AUTO:START -->

## Latest automated snapshot

_No data yet. Run `npm run metrics -- --days=14` to populate this section._

<!-- METRICS_AUTO:END -->
