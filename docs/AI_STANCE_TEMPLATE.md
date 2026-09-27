# AI Stance — <PROJECT NAME>

> **Status**: Authoritative. This file is the single source of truth for AI policy in this repository.
> **Last reviewed**: YYYY-MM-DD
> **Next review due**: YYYY-MM-DD (quarterly)
> **Review cadence**: Quarterly or when a new AI tool is adopted
> **Feedback**: Raise a GitHub issue tagged `ai-stance` with concerns or Prohibited-item violations

---

## 1. Expectation of Use

AI use in this repository is **expected / encouraged / optional / discouraged**.

**Why**: <One sentence explaining the rationale — not just _that_ AI is permitted, but _why_ this level of expectation matches the project's goals, risk profile, and team capabilities.>

**Applies to**: Humans and AI agents alike. Agent sessions MUST load this stance at startup (see `context-engineering` skill).

---

## 2. Organizational Support

This stance is backed by repository infrastructure, not convention:

- **Always-loaded policy**: `AGENTS.md` (symlinked to `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, `GEMINI.md`)
- **Skills**: `ai-stance` and `ai-policy-lifecycle` own this document and its quarterly review
- **Pre-commit hooks**: Gitleaks, detect-secrets, shellcheck, DORA vocabulary, AI stance audit
- **Contract assertions**: `.agents/assertions/` validate agent reports

---

## 3. Permitted Tools — Three Buckets

### Prohibited (Never Use)

| Tool / Practice | Reason |
|----------------|--------|
| <Tool> | <Specific, auditable reason — e.g., "sends source code to external API without audit"> |
| <Tool> | <Reason> |
| <Tool> | <Reason> |

> A sparse Prohibited list indicates the policy was not thought through. Minimum 3 items.

### Permitted with Guardrails (Use Only Under These Conditions)

| Tool | Version / Model | Guardrail Condition (Must All Be True) |
|------|-----------------|----------------------------------------|
| <Tool> | <Pinned version, e.g., `anthropic/claude-3.5-sonnet-20241022`> | <Explicit, checkable condition — e.g., "Only for code generation in `src/`; PR must pass `check-agents.sh`"> |
| <Tool> | <Pinned version> | <Condition> |

> No tool may appear in Allowed that should have guardrails given current usage patterns. Each item has an explicit, specific guardrail condition.

### Allowed (Use Freely)

| Tool | Version / Model | Notes |
|------|-----------------|-------|
| <Tool> | <Pinned version> | <Optional note> |
| <Tool> | <Pinned version> | <Optional note> |

> No unpinned tools (no "latest", no "<model-id>", no TBD). All versions are current as of Last reviewed date.

---

## 4. Role Applicability & Agent Obligations

| Role | Applies? | Specific Obligations |
|------|----------|---------------------|
| Human contributors | Yes | Load stance at session start; halt on Prohibited items |
| AI agents (all) | Yes | Load `ai-stance` skill at startup; log session; halt on Prohibited |
| `@planner` | Yes | Plans must not reference Prohibited tools |
| `@builder` | Yes | Implementation must use only Permitted/Allowed tools |
| `@verifier` | Yes | Block if Prohibited tool evidence found in artifacts |
| `@operator` | Yes | Release only after stance audit passes |

---

## Enforcement Honesty Table

| Claim | Reality | Workflow / Evidence |
|-------|---------|---------------------|
| SAST blocks merge | No Semgrep/CodeQL workflow runs | Advisory only; Semgrep would run in `agent-ci.yml` if added |
| Dependency scanning gates on CVEs | No `dependency-review` action blocks | Advisory; Trivy writes to job summary with `&#124;&#124; true` |
| Container scanning blocks deploy | No image scanner blocks | Advisory; Trivy runs in CI, results in summary only |
| Secret detection blocks commit | **Yes** — gitleaks + detect-secrets in pre-commit | `.pre-commit-config.yaml` hooks |
| AI stance audit blocks commit | **Yes** — `check-ai-stance.sh` in pre-commit | `scripts/check-ai-stance.sh` |
| DORA vocabulary blocks commit | **Yes** — `check-dora-vocabulary.sh` in pre-commit | `scripts/check-dora-vocabulary.sh` |
| Agent dispatch validates | **Yes** — `check-agents.sh` in pre-commit | `scripts/check-agents.sh` |
| Harness parity validates | **Yes** — `check-harness-parity.sh` in pre-commit | `scripts/check-harness-parity.sh` |

---

## Currency Checklist (Quarterly)

- [ ] `Last reviewed` date updated
- [ ] `Next review due` date set (quarterly)
- [ ] No `[PLACEHOLDER]` strings remain
- [ ] All tool versions pinned and current (check provider model lists)
- [ ] Prohibited list has ≥3 items with auditable reasons
- [ ] Every Permitted-with-guardrails item has explicit, checkable condition
- [ ] No tool in Allowed that should have guardrails
- [ ] Feedback mechanism documented and reachable

---

## Changelog

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| YYYY-MM-DD | 1.0.0 | Initial stance | <author> |

---

## Appendix: DORA AI Capability Mapping

This stance directly implements **DORA AI Capability 1: Clear and communicated AI stance** and supports:

- **Capability 3: AI-accessible internal data** — via `AGENTS.md` context index and `context-engineering` skill
- **Capability 4: Strong version control practices** — via conventional commits, PR size gates
- **Capability 5: Working in small batches** — via TDD requirement, PR size blocking
- **Capability 6: User-centric focus** — via `discover` skill, `platform-feedback`
- **Capability 7: Quality internal platforms** — via `docs/GOLDEN_PATH.md`, `preflight`, agent specialists
