# AI Policy — starter template for downstream repositories

> **Status in this repository:** this is a **template, not policy**.
>
> The authoritative AI stance for `paruff/uFawkesAI` is **[`AI_STANCE.md`](../AI_STANCE.md)**
> at the repository root, maintained by the `ai-stance` skill and reviewed
> quarterly. This file exists so that repositories copied from this template
> have a starting point to fill in for themselves.
>
> Do not treat the placeholders below as resolved for this repository. Copy
> this file into a new project and replace every `[PLACEHOLDER]` and
> `[PROJECT NAME]` with that project's own answers, or adopt `AI_STANCE.md`
> as the policy format directly — it carries the same content in the
> three-bucket structure that the `ai-stance` audit checks.

> DORA AI Cap 1 finding: "A clear AI stance provides psychological safety for
> experimentation. Ambiguity around AI use creates friction, reduces adoption,
> and harms team morale."
>
> DORA 2025 finding: "30% of developers report little or no trust in AI-generated
> code — and having appropriate skepticism is correct. The policy response is
> clarity, not mandated trust."
>
> Once filled in for a downstream project, this document becomes that
> project's official AI policy and is reviewed quarterly.

---

## Our AI Stance

We use AI agents to accelerate software delivery. We do not use AI to replace
human judgment, architectural decisions, or quality accountability.

**AI implements. Humans decide.**

---

## What AI Is Used For

_(template: replace with that project's actual usage)_

| Use Case                      | Tool                 | Human Oversight                       |
| ----------------------------- | -------------------- | ------------------------------------- |
| Code generation from PM specs | GitHub Copilot agent | Human review before merge             |
| Test generation               | `@builder` (`test` skill) | Human confirms tests are meaningful   |
| Documentation generation      | Any agent session    | Human reviews for accuracy            |
| Code review pre-screening     | `@verifier`          | Human makes final review decision     |
| Security scanning             | `security-testing` skills | Human escalates all CRITICAL findings |
| Debugging assistance          | Copilot Chat         | Human verifies the fix                |

---

## What AI Is NOT Used For

- Architectural decisions (which patterns, where code lives, how layers are structured)
- Security-sensitive configuration (auth flows, secret management, Firestore rules)
- Adding new dependencies (requires PM + human developer sign-off)
- Merging PRs (humans merge — always)
- Responding to production incidents (humans lead; AI assists with investigation)

---

## Psychological Safety Norms (DORA 2025 PSYCH-01)

> DORA 2025: "Psychological safety is strongly predictive of high software delivery
> performance — and AI adoption without psychological safety creates anxiety, not productivity."

**Team agreements:**

1. **Anyone may decline AI assistance on any task.** No justification required.
2. **AI skepticism is not resistance to change.** Questioning AI output is encouraged — it is the review process working correctly.
3. **Mistakes with AI-generated code are learning opportunities**, not failures. The review process is designed to catch them.
4. **Concerns about AI quality or direction** are raised openly — in retrospectives, in the DEVEX_LOG, or directly to the PM.
5. **Human judgment overrides AI output** in all cases, without friction.

---

## Data Handling

[PLACEHOLDER — fill in your actual data policy. Example:]

- **Acceptable context for AI:** Source code, internal architecture docs, non-PII test data
- **Not acceptable:** Customer PII, credentials, production database contents, private keys
- **Where prompts are processed:** [GitHub Copilot / your AI provider] — see their data retention policy
- **Logging:** AI sessions are not logged beyond what the AI provider retains

---

## Accountability

- **Who sets AI policy:** [PM / Tech Lead / both] — reviewed quarterly
- **Who owns the instructions files:** Human developers — agents cannot modify `AGENTS.md`
- **How we handle AI-introduced bugs:** Follow `docs/RUNBOOKS.md` → Change Failure Response
- **Who approves large PRs:** Human reviewer only — the `large-pr-approved` label is humans-only

---

## Policy Review Cadence

This document is reviewed quarterly. Trigger a review if:

- Rework rate exceeds 20% for two consecutive months
- A new AI capability is being adopted (new agent, new tool)
- A significant AI-introduced incident occurs in production
- Team DevEx score for "AI Trust" falls below 3

**Last reviewed:** [PLACEHOLDER — date]
**Next review:** [PLACEHOLDER — date]
