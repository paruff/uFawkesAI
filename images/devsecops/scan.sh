#!/usr/bin/env bash
# images/devsecops/scan.sh — vulnerability scan policy for the DevSecOps
# images (docs/ai-sdlc/devsecops-image/spec.md R5). Runs inside the core
# image with the Docker socket mounted:
#
#   docker run --rm --user root -v /var/run/docker.sock:/var/run/docker.sock \
#     -v "$PWD/images/devsecops:/devsecops:ro" -v "$PWD/scan-out:/out" \
#     fawkes-space-core:<tag> /devsecops/scan.sh <image> <gate-exit-code>
#
# 1. Report (never fails): every CRITICAL/HIGH with a fix available across
#    the whole image, summarised per target into /out/trivy-report.md.
# 2. Gate (exit <gate-exit-code> on findings): the same severities, limited
#    to what this repo controls — Debian packages (apt snapshot) and the
#    locked Python/npm deps under /opt/ufawkes. Upstream prebuilt binaries
#    (/usr/local/bin) and npm's bundled deps (/usr/local/lib/node_modules)
#    are excluded: only an upstream rebuild fixes those, and the lock-bump
#    workflow picks up such releases.
#
# Accepted exceptions: /devsecops/.trivyignore (reason + expiry per entry).

set -euo pipefail

IMAGE="${1:?usage: $0 <image> [gate-exit-code]}"
GATE_EXIT="${2:-1}"
OUT="${OUT_DIR:-/out}"
mkdir -p "$OUT"

common=(--no-progress --scanners vuln --severity "CRITICAL,HIGH" --ignore-unfixed
  --ignorefile /devsecops/.trivyignore)

echo "== 1. Report: whole image (informational) =="
trivy image "${common[@]}" --format json --output "$OUT/trivy-all.json" "$IMAGE"
{
  echo "### Trivy — fixable CRITICAL/HIGH across \`${IMAGE}\` (report only)"
  echo
  echo "| Target | Critical | High | Gated (repo-controlled) |"
  echo "| ------ | -------- | ---- | ----------------------- |"
  # A finding is upstream-only when its package lives under the skipped dirs
  # (PkgPath for language packages; the Target itself for Go binaries).
  jq -r '.Results[]
    | .Target as $t
    | select((.Vulnerabilities // []) | length > 0)
    | [$t,
       ([.Vulnerabilities[] | select(.Severity == "CRITICAL")] | length),
       ([.Vulnerabilities[] | select(.Severity == "HIGH")] | length),
       ([.Vulnerabilities[]
         | select((.PkgPath // $t) | test("^usr/local/(bin|lib/node_modules)/") | not)] | length)]
    | "| `\(.[0])` | \(.[1]) | \(.[2]) | \(.[3]) |"' "$OUT/trivy-all.json"
} | tee "$OUT/trivy-report.md"

echo
echo "== 2. Gate: Debian packages + locked Python/npm deps =="
trivy image "${common[@]}" \
  --skip-dirs /usr/local/bin --skip-dirs /usr/local/lib/node_modules \
  --exit-code "$GATE_EXIT" "$IMAGE"
