#!/usr/bin/env bash
# agent-metrics.sh — Report on agent and skill invocation patterns
# DORA Cap 3 (Context Engineering): measure which agents/skills actually fire
# Usage: bash scripts/agent-metrics.sh [--days=N] [--verbose] [--save]
set -euo pipefail

DAYS=30
VERBOSE=0
SAVE=0

for arg in "$@"; do
  case "$arg" in
    --days=*) DAYS="${arg#*=}" ;;
    --verbose) VERBOSE=1 ;;
    --save) SAVE=1 ;;
    *) echo "Usage: bash scripts/agent-metrics.sh [--days=N] [--verbose] [--save]"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${REPO_ROOT}/.agents/logs"
export SNAPSHOT_UTC="$(date -u +"%Y-%m-%d %H:%M:%SZ")"

if [ ! -d "${LOG_DIR}" ]; then
  echo "No .agents/logs/ directory found. Create it and add invocation logs to get started."
  exit 0
fi

# Find all .jsonl log files
declare -a LOG_FILES=()
while IFS= read -r -d '' f; do
  LOG_FILES+=("$f")
done < <(find "${LOG_DIR}" -name "*.jsonl" -print0 2>/dev/null || true)

if [ ${#LOG_FILES[@]} -eq 0 ]; then
  echo "No invocation logs found."
  echo ""
  echo "Logs go in .agents/logs/ as .jsonl files (one JSON object per line, one line per invocation)."
  echo "Each agent writes its log after completing its task per the logging protocol."
  exit 0
fi

# Delegate aggregation to Python for portability (bash 3 on macOS has no associative arrays)
export DAYS_FILTER="${DAYS}"
report="$(python3 - "${LOG_FILES[@]}" <<'PY'
import datetime, json, os, sys
from collections import Counter

log_files = sys.argv[1:]
days_filter = int(os.environ.get("DAYS_FILTER", "0"))

total_invocations = 0
total_findings = 0
total_blockers = 0
total_manual = 0

agent_counts = Counter()
agent_findings = Counter()
skill_counts = Counter()
decision_counts = Counter()
severity_counts = Counter()

cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=days_filter) if days_filter > 0 else None

for f in log_files:
    with open(f) as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            # Skip entries older than --days=N cutoff
            if cutoff is not None:
                ts = entry.get("timestamp")
                if ts:
                    try:
                        entry_time = datetime.datetime.fromisoformat(ts)
                        if entry_time.tzinfo is None:
                            entry_time = entry_time.replace(tzinfo=datetime.timezone.utc)
                        if entry_time < cutoff:
                            continue
                    except (ValueError, TypeError):
                        pass

            total_invocations += 1
            agent = entry.get("agent", "unknown")
            decision = entry.get("decision", "unknown")
            blockers = entry.get("blockers", 0)
            findings = entry.get("findings", [])

            agent_counts[agent] += 1
            decision_counts[decision] += 1
            total_blockers += blockers
            agent_findings[agent] += len(findings)
            total_findings += len(findings)

            for skill in entry.get("skills_loaded", []):
                skill_counts[skill] += 1

            for f_item in findings:
                sev = f_item.get("severity", "INFO")
                severity_counts[sev] += 1
                if f_item.get("manual_review_needed", False):
                    total_manual += 1

# Build report
lines = []
lines.append("## Agent Metrics Snapshot")
lines.append("")
lines.append(f"Generated on **{os.environ.get('SNAPSHOT_UTC', 'unknown')}**.")
lines.append("")
lines.append("### Summary")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|--------|-------|")
lines.append(f"| Total invocations | {total_invocations} |")
lines.append(f"| Total findings | {total_findings} |")
lines.append(f"| Total blockers (CRITICAL) | {total_blockers} |")
lines.append(f"| Findings requiring manual review | {total_manual} |")
lines.append("")
lines.append("### Invocations per Agent")
lines.append("")
lines.append("| Agent | Invocations | Findings | Findings/Invocation |")
lines.append("|-------|------------|----------|---------------------|")

for agent in sorted(agent_counts.keys()):
    count = agent_counts[agent]
    findings = agent_findings[agent]
    ratio = round(findings / count, 1) if count > 0 else 0
    lines.append(f"| {agent} | {count} | {findings} | {ratio} |")

lines.append("")
lines.append("### Decisions")
lines.append("")
lines.append("| Decision | Count |")
lines.append("|----------|-------|")

for decision in sorted(decision_counts.keys()):
    lines.append(f"| {decision} | {decision_counts[decision]} |")

lines.append("")
lines.append("### Findings by Severity")
lines.append("")
lines.append("| Severity | Count |")
lines.append("|----------|-------|")

for sev in ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO"]:
    count = severity_counts.get(sev, 0)
    lines.append(f"| {sev} | {count} |")

lines.append("")
lines.append("### Skills Loaded (top 10)")
lines.append("")
lines.append("| Skill | Load Count |")
lines.append("|-------|-----------|")

for skill, count in skill_counts.most_common(10):
    lines.append(f"| {skill} | {count} |")

lines.append("")
lines.append("### Notes")
lines.append("")
lines.append("- **Actionability rate** requires adding `actionable: true/false` to each finding in the invocation log.")
lines.append(f"- **Manual review burden** = {total_manual} findings require human judgment. Review if this is trending up.")
blocker_density = round((total_blockers * 100) / total_invocations, 0) if total_invocations > 0 else 0
lines.append(f"- **Blocker density** = {int(blocker_density)}% of invocations produced blockers.")

print("\n".join(lines))
PY
)"

# Output
if [ "${SAVE}" -eq 1 ]; then
  METRICS_DOC="${REPO_ROOT}/docs/AGENT_METRICS.md"
  if [ -f "${METRICS_DOC}" ]; then
    tmp_file="$(mktemp)"
    report="${report}" python3 - "${METRICS_DOC}" <<'PY' >"${tmp_file}"
import os, pathlib, re, sys
content = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
block = os.environ["report"]
pattern = r"<!-- AGENT_METRICS_AUTO:START -->.*?<!-- AGENT_METRICS_AUTO:END -->"
if re.search(pattern, content, flags=re.S):
    updated = re.sub(pattern, block, content, flags=re.S)
else:
    updated = content.rstrip() + "\n\n" + block + "\n"
print(updated, end="")
PY
    mv "${tmp_file}" "${METRICS_DOC}"
    echo "Updated ${METRICS_DOC}"
  else
    echo "AGENT_METRICS.md not found; run with --save only after it exists."
    echo ""
    printf "%s\n" "$report"
  fi
fi

if [ "${VERBOSE}" -eq 1 ] || [ "${SAVE}" -eq 0 ]; then
  printf "%s\n" "$report"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Agent Metrics — ${#LOG_FILES[@]} log files scanned"
echo "  Timestamp: ${SNAPSHOT_UTC}"
echo "═══════════════════════════════════════════"
