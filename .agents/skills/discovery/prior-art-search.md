---
name: discovery/prior-art-search
description: "Structured search for existing solutions before building. Checks the uFawkes* suite, the Dojo, and open-source projects. Implements the 'compose rather than build' principle. Use at the end of every discovery session before writing the spec."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: discovery
---

# Sub-Skill: Discovery — Prior Art Search

> **Load trigger:** `"load discovery/prior-art-search skill"`
> **DORA:** AI Capability 5 (Working in small batches) + AI Capability 3 (AI-accessible internal data)
> **Token cost:** Low
> **When to use:** End of every discovery session, before writing spec.

## Purpose

"Compose rather than build" is the highest-leverage YAGNI principle in a solo-contributor
portfolio. If the capability already exists — in another uFawkes\* repo, in the Dojo,
or in a well-maintained open-source project — the right move is to integrate it,
not rebuild it.

Spending 15 minutes here can eliminate an entire sprint of unnecessary work.

## Search Layers (run in order — stop when you find a match)

### Layer 1 — Internal: uFawkes\* repos (5 min)

```bash
# Search all local uFawkes* repos for relevant functionality
QUERY="SEARCH_TERM"  # replace with key terms from the JTBD

for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI; do
  REPO_PATH="../${repo}"
  [ -d "$REPO_PATH" ] || continue
  echo "=== ${repo} ==="
  # Search README for capability description
  grep -in "${QUERY}" "${REPO_PATH}/README.md" 2>/dev/null | head -3
  # Search any architecture docs
  grep -rin "${QUERY}" "${REPO_PATH}/ARCHITECTURE.md" "${REPO_PATH}/docs/" 2>/dev/null | head -3
  # Search skill files
  grep -rin "${QUERY}" "${REPO_PATH}/.agents/" 2>/dev/null | head -3
done

# Also check the current repo's own test suite and scripts
grep -rn "${QUERY}" tests/ scripts/ .agents/ 2>/dev/null | head -5
```

**Match criteria:** If any repo has a documented feature, skill, or script that
covers >70% of the JTBD, it's prior art. Document it and propose composition.

### Layer 2 — Internal: Dojo content (3 min)

```bash
# Check if this capability is already taught in the Dojo
grep -rin "${QUERY}" docs/dojo/ 2>/dev/null | head -5
# Check ufawkes.dev if accessible
# gh issue list --repo paruff/ufawkes.dev --search "${QUERY}" --state all | head -5
```

If the capability is already in the Dojo, the right move is usually to extend the
existing lab, not create a parallel implementation.

### Layer 3 — GitHub: uFawkes issues and PRs (3 min)

```bash
# Check if this was already proposed, attempted, or closed as won't-fix
for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesAI; do
  gh issue list --repo "paruff/${repo}" --search "${QUERY}" --state all \
    --json number,title,state,labels \
    --jq ".[] | \"[${repo}] #\(.number) [\(.state)]: \(.title)\"" 2>/dev/null
done
```

A closed issue with `wont-fix` or `duplicate` is signal. Understand why before
proposing the same thing again.

### Layer 4 — Open source (4 min)

Search these sources in order. Stop at the first credible match.

```bash
# 1. CNCF landscape (for platform/infra capabilities)
echo "Check: https://landscape.cncf.io/ for [capability]"

# 2. GitHub search for active projects
gh search repos "${QUERY} stars:>100 pushed:>2025-01-01" --limit 5 \
  --json fullName,description,stargazersCount,updatedAt \
  --jq '.[] | "\(.fullName) ★\(.stargazersCount): \(.description)"'

# 3. Known reference implementations for common capabilities
KNOWN_PRIOR_ART=(
  "observability stack: grafana/grafana, prometheus/prometheus, grafana/loki, open-telemetry/opentelemetry-collector"
  "CI pipeline: woodpecker-ci/woodpecker, tektoncd/pipeline"
  "GitOps: fluxcd/flux2, argoproj/argo-cd"
  "CDE: coder/coder, coder/code-server, devcontainers/spec"
  "golden paths: backstage/backstage, roadie-gg/roadie-backstage-plugins"
  "DORA metrics: dora-team/fourkeys, LinearB, Sleuth"
  "security policy: open-policy-agent/opa, kyverno/kyverno"
)
echo "Known prior art for related domains:"
for item in "${KNOWN_PRIOR_ART[@]}"; do echo "  - $item"; done
```

## Composition Decision Matrix

| Finding                                             | Decision                                                                         |
| --------------------------------------------------- | -------------------------------------------------------------------------------- |
| Exact match in uFawkes\* suite                      | **Compose:** use existing skill/feature; open issue to improve it if it has gaps |
| Partial match in uFawkes\* suite                    | **Extend:** build on existing, don't create parallel implementation              |
| Exact match in open source (maintained, MIT/Apache) | **Integrate:** wrap or reference it; document the dependency                     |
| Partial match in open source                        | **Extend or fork:** evaluate maintenance burden before deciding                  |
| No match anywhere                                   | **Build:** proceed to spec; document why existing solutions don't apply          |

## Output Section for Discovery Brief

```markdown
## Prior Art Search (from prior-art-search sub-skill)

**Search terms:** [terms used]
**Date:** YYYY-MM-DD

### Internal (uFawkes\* suite)

- [repo]: [what exists, why it doesn't fully cover the need]
- No match found / [match description]

### Dojo

- [existing module or no match]

### Open source

- [project name + URL]: [what it does, why it does/doesn't fit]
- No credible match found

### Decision

[Build from scratch | Compose with X | Extend X | Integrate X]

**Rationale:** [one sentence — why this is the right composition decision]

**Composition approach:** [if not build-from-scratch — how exactly to use the existing solution]
```

## Output Format

```json
{
  "sub-skill": "discovery/prior-art-search",
  "query_terms": ["string"],
  "internal_matches": [
    {
      "repo": "uFawkesObs",
      "component": "observability skill",
      "coverage": 0.7
    }
  ],
  "dojo_matches": [],
  "open_source_matches": [],
  "decision": "extend | compose | integrate | build",
  "selected_prior_art": "uFawkesObs/observability skill",
  "composition_approach": "string",
  "discovery_brief_updated": true
}
```
