# Specification — Placeholder audit

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 1

**REQ-001.** `scripts/check-placeholders.sh` lists every tracked file:line
containing a `[PLACEHOLDER…]` marker, skipping `scripts/` (which talks about
the marker) and backticked mentions.

**REQ-002.** With `.template` present, it reports and exits 0. Without it,
or with `PLACEHOLDER_ENFORCE=1`, any marker exits 1.

**REQ-003.** `scripts/preflight.sh` and `scripts/verify.sh` use it;
`PREFLIGHT_ENFORCE_PLACEHOLDERS=1` still forces enforcement.

**REQ-004.** `scripts/setup.sh` deletes `.template` (dry-run prints it).
`docs/GOLDEN_PATH.md` documents this as Step 0.
