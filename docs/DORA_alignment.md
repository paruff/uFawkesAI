# Alignment with DORA's AI research

Grounded in two reports fetched directly for this plan:
- DORA, *2025 AI Capabilities Model* (Google, retrieved 2026)
- DORA, *ROI of AI-assisted Software Development* (v2026.1, Google)

A third, *2025 State of AI-assisted Software Development*, is cited
extensively by both of the above but was not independently fetched in full
for this plan — check it directly at https://dora.dev/dora-report-2025 for
the underlying survey methodology and full statistics.

## Direct hits — what this plan is already doing right

**Strong version control practices** (one of DORA's seven named AI
capabilities): explicitly recommends trunk-based development ("minimize
long-lived branches, promote frequent integration") and Conventional Commits
by name. Phase 0 of `feature-flow.md` and `docs/COMMIT_CONVENTIONS.md`
directly implement this.

**The "verification tax"**: DORA's ROI report names this as a real,
measurable cost — developers spending time reviewing AI output because trust
is low, which deepens the "J-Curve" productivity dip during adoption. Your
`verification.md` / `cross-validation.md` split, and now the live-system
verification phase, are direct countermeasures. Important nuance: DORA's
framing of the verification tax is about *reviewing generated code*, not
specifically about *testing against a live running system* — the live-system
gap is an adjacent problem you identified independently, not something DORA's
report calls out by name. I don't have a verified DORA citation for "test
against live systems specifically" — treat that as sound engineering
judgment, not a research-backed capability.

**Working in small batches**: DORA found this improves product performance
but has a measured *negative* effect on self-reported individual
effectiveness (their hypothesis: decomposition overhead offsets raw
generation speed). Relevant because adding more phase gates (Phase 3.5, the
permission allowlists) will very plausibly *feel* slower even while it
improves the metrics that actually matter. DORA's own framing: expect an
initial adoption dip (approximately 15% productivity drop over about three
months in their sample ROI model) as "tuition cost," not a sign the system is
wrong.

**Feature flags / decoupling deploy from release**: DORA recommends this as
part of small-batch discipline. Not currently addressed anywhere in your
agent files — worth considering if `feature-flow.md`'s trunk-daily discipline
starts producing partially-complete features that need to reach trunk before
they're user-ready.

## What DORA measures that your logs could now feed

DORA's five core software delivery metrics — lead time for changes,
deployment frequency, failed deployment recovery time, change failure rate,
and deployment rework rate — are exactly the kind of thing your
`session_id`-linked JSONL logs (once #5 and #13 close the gaps) could
progressively feed:

- `feature-flow`'s Phase 0→5 duration → lead time for changes
- `repair-flow`'s `root_cause_category` + `originating_session_id` → change
  failure rate, once linked back to the feature-flow session that introduced
  the failure
- Live-system verification pass/fail at Phase 3.5, fed forward into a
  post-deploy smoke test (plan issue #12) → change failure rate at the
  production level, not just pre-merge

## Honest gap

Nothing in the two reports I fetched gives a benchmarked number for "how much
does live-system testing reduce change failure rate specifically" — that's a
reasonable hypothesis, not a cited finding. Recommend treating it the way
DORA recommends treating any of its own findings: as a hypothesis to test
against your own before/after metrics, not an assumed truth.
