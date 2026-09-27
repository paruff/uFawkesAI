#!/usr/bin/env bash
# templates/tests/smoke/test_woodpecker_health.sh — proves Woodpecker CI is running and accessible.
#
# Woodpecker CI uses a SQLite/PostgreSQL backend and a gRPC server.
# This test validates the Woodpecker server and agent connectivity.
#
# Needs bash, curl, docker. No third-party modules.
#
# Exit 0 = every check passed.

set -euo pipefail

# Configuration
WOODPECKER_HOST="${WOODPECKER_HOST:-localhost}"
WOODPECKER_PORT="${WOODPECKER_PORT:-9000}"
WOODPECKER_URL="http://${WOODPECKER_HOST}:${WOODPECKER_PORT}"
AGENT_HOST="${WOODPECKER_AGENT_HOST:-localhost}"
AGENT_PORT="${WOODPECKER_AGENT_PORT:-9001}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

pass=0
failures=()

check() { # check <label> <condition>
    local label="$1"
    local condition="$2"
    if eval "$condition"; then
        pass=$((pass + 1))
        echo "  ✅ $label"
    else
        failures+=("$label")
        echo "  ❌ $label"
    fi
}

echo "== Woodpecker CI Health Checks =="

# 1. Woodpecker server health endpoint
echo "-- Server health --"
if curl -sf "${WOODPECKER_URL}/healthz" >/dev/null 2>&1; then
    check "Woodpecker server /healthz" "true"
else
    check "Woodpecker server /healthz" "false"
fi

# 2. Woodpecker API responds
if curl -sf "${WOODPECKER_URL}/api/repos" >/dev/null 2>&1; then
    check "Woodpecker API /api/repos" "true"
else
    check "Woodpecker API /api/repos" "false"
fi

# 3. Woodpecker agent connectivity
echo "-- Agent connectivity --"
if curl -sf "http://${AGENT_HOST}:${AGENT_PORT}/healthz" >/dev/null 2>&1; then
    check "Woodpecker agent /healthz" "true"
else
    check "Woodpecker agent /healthz" "false"
fi

# 4. Docker daemon accessible (required for Woodpecker)
if docker info >/dev/null 2>&1; then
    check "Docker daemon accessible" "true"
else
    check "Docker daemon accessible" "false"
fi

# 5. Woodpecker CLI available (optional)
if command -v woodpecker-cli >/dev/null 2>&1; then
    check "woodpecker-cli installed" "true"
else
    check "woodpecker-cli installed" "false"
fi

echo
echo "Health checks: ${pass} passed, ${#failures[@]} failed"
if [ ${#failures[@]} -gt 0 ]; then
    for f in "${failures[@]}"; do
        echo "  FAILED: $f"
    done
    exit 1
fi
exit 0
