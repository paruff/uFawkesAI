#!/usr/bin/env bash
# scripts/image-gate-decide.sh <branch|tag> <pinned-rc> <fresh-rc|none|unavailable>
#
# Outcome of the image Trivy gate (build-cde-space-image.yml), given the scan
# of the pinned apt snapshot and, when that failed, of today's snapshot. Tells a
# stale lock (a bump clears it) from a finding no snapshot fixes. What ships is
# always the pinned image, so a tag fails on any pinned finding.
set -euo pipefail

kind="${1:-}" pinned="${2:-}" fresh="${3:-none}"
case "$kind" in branch | tag) ;; *)
  echo "usage: $0 <branch|tag> <pinned-rc> <fresh-rc|none|unavailable>" >&2
  exit 2
  ;;
esac
[[ "$pinned" =~ ^[0-9]+$ ]] || {
  echo "usage: pinned-rc must be a number" >&2
  exit 2
}

if [ "$pinned" -eq 0 ]; then
  echo "Gate passed on the pinned snapshot."
  exit 0
fi
if [ "$fresh" = 0 ]; then
  if [ "$kind" = tag ]; then
    echo "::error::Stale lock: the pinned apt snapshot has fixable findings that today's snapshot clears. Merge the image-lock-bump PR (or run image-lock-bump.yml), then re-dispatch this tag."
    exit 1
  fi
  echo "::warning::Stale lock: the pinned apt snapshot has fixable findings that today's snapshot clears. A bump PR is pending; merge it before the next release."
  exit 0
fi
echo "::error::Findings persist on the newest snapshot (fresh scan: ${fresh}); a lock bump does not clear them."
exit 1
