---
name: ai-stance
description: "Generate and maintain AI_STANCE.md for any uFawkes* repo. Use when onboarding a repo to the uFawkesAI suite, when reviewing AI policy currency, or when a new AI tool is being adopted. Implements DORA AI Capability 1."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: AI Stance

> **Load trigger:** `"load ai-stance skill"` > **DORA:** AI Capability 1 (Clear and communicated AI stance)
> **Token cost:** Low

## Purpose

Produce and maintain `AI_STANCE.md` — the document that gives every contributor
(human and agent) unambiguous clarity on how AI tools are used in this repo.
Ambiguity creates risk; clarity creates psychological safety for effective experimentation.

DORA AI Capabilities Model v2025.1 identifies four required clarity dimensions:
expectation of use, organizational support, permitted tools, and role applicability.
This skill ensures all four are present.

## Three-Bucket Framework

Every AI_STANCE.md must classify all AI tool usage into exactly three buckets.
No "it depends" without specifying what it depends on.

| Bucket                        | Definition                                          | Decision rule                                  |
| ----------------------------- | --------------------------------------------------- | ---------------------------------------------- |
| **Prohibited**                | Never permitted in this repo, regardless of context | Safety, compliance, or trust boundary violated |
| **Permitted with guardrails** | Allowed when stated conditions are met              | Default for most AI-assisted development       |
| **Allowed**                   | No special conditions required                      | Low-risk, fully reversible, human-verifiable   |

## Default Stance for uFawkes\* Repos

Pre-populated for the fawkes suite. Override per repo as needed.

### Prohibited

- Sending PII, secrets, or proprietary infrastructure configs to public AI models
- Committing AI-generated code without running pre-commit hooks
- Bypassing branch protection rules because "the AI said it was fine"
- Using AI to generate security policy or compliance documentation without human expert review
- AI-generated content in Dojo modules without disclosure to learners

### Permitted with Guardrails

| Use                                             | Guardrail                                                      |
| ----------------------------------------------- | -------------------------------------------------------------- |
| AI-generated code merged to main                | Human review required; at least one test covering the new code |
| AI-assisted spec / design documents             | Discovery brief must exist first (discover agent ran)          |
| Agent sessions modifying infrastructure configs | j-curve-navigation pre-flight check must pass                  |
| AI-generated release notes                      | Human review before publishing                                 |
| opencode sessions in any uFawkes\* repo         | Session must load AGENTS.md and relevant skills first          |
| graphify corpus built from internal docs        | Corpus must not include files containing secrets or PII        |

### Allowed

- AI-assisted code completion (Copilot, Claude Code) for any file not in Prohibited list
- AI-generated first drafts of blog posts, dev.to articles, LinkedIn posts
- AI-assisted issue triage and labeling
- AI-generated test stubs (human completes and verifies)
- Asking AI tools to explain existing code or documentation

## Four Required Clarity Dimensions

The generated `AI_STANCE.md` must answer all four:

1. **Expectation of use** — Is AI use expected, encouraged, optional, or discouraged here?
2. **Organizational support** — What tooling is provided? What training/docs exist?
3. **Permitted tools** — Exact tool names and versions (not "any LLM")
4. **Role applicability** — Does this stance apply to agents, humans, or both?

## Permitted Tools Reference (uFawkes suite defaults)

| Tool                   | Version / model   | Permitted scope                                    |
| ---------------------- | ----------------- | -------------------------------------------------- |
| opencode               | Latest stable     | All repos — primary agentic development tool       |
| Claude (Anthropic API) | <current model — check anthropic.com/models> | All repos — skill and agent authoring, code review |
| graphify               | [confirm variant] | All repos — context corpus building                |
| ponytail               | Latest stable     | All repos — YAGNI enforcement                      |
| GitHub Copilot         | Current           | IDE completion only                                |

**Note:** Confirm graphify variant (safishamsi/graphify vs rhanka/graphify) before
publishing AI_STANCE.md. They are different tools with the same name.

## AI_STANCE.md Template

```markdown
# AI Stance — [REPO_NAME]

> Last reviewed: YYYY-MM-DD
> Next review due: YYYY-MM-DD (quarterly)
> Owner: [GITHUB_USERNAME]
> Suite: uFawkesAI

## Expectation of Use

AI-assisted development is [expected / encouraged / optional] in this repo.
[One sentence on why — e.g., "We use AI to clear bottlenecks in the product lifecycle,
not to replace human judgment on architecture and security decisions."]

## Organizational Support

- Permitted tools: listed in the table below
- Skill suite: uFawkesAI `.agents/skills/` — load relevant skills before each session
- Questions or policy concerns: file a GitHub issue with label `ai-policy`
- Policy reviews: quarterly (see ai-policy-lifecycle skill)

## Permitted Tools

| Tool           | Model / version   | Scope                               |
| -------------- | ----------------- | ----------------------------------- |
| opencode       | latest            | Agentic development sessions        |
| Claude         | <current model> | Skill authoring, review, generation |
| graphify       | [variant]         | Context corpus                      |
| ponytail       | latest            | YAGNI enforcement                   |
| GitHub Copilot | current           | IDE completion                      |

## Three-Bucket Classification

### Prohibited

[Fill from default stance above, plus any repo-specific additions]

### Permitted with Guardrails

[Fill from default stance above, plus any repo-specific additions]

### Allowed

[Fill from default stance above, plus any repo-specific additions]

## Role Applicability

This stance applies to: human contributors AND AI agents (opencode sessions,
GitHub Actions opencode workflow, any automated agent invocation).
Agents must load `ai-stance` skill and verify this document exists before beginning
substantive work.
```

## Session Actions

When this skill is loaded, the agent should:

1. Check whether `AI_STANCE.md` exists at repo root
2. If missing: generate it using the template above, prompt human for repo-specific overrides
3. If present: check `Last reviewed` date — warn if >90 days old
4. Verify all four clarity dimensions are present
5. Verify all listed tools are still current (no EOL tools in Permitted list)
6. Output stance-report.json

## Output Format

```json
{
  "skill": "ai-stance",
  "status": "present | missing | stale",
  "ai_stance_path": "AI_STANCE.md",
  "last_reviewed": "YYYY-MM-DD",
  "days_since_review": 42,
  "review_overdue": false,
  "clarity_dimensions_present": {
    "expectation_of_use": true,
    "organizational_support": true,
    "permitted_tools": true,
    "role_applicability": true
  },
  "prohibited_count": 5,
  "guardrail_count": 6,
  "allowed_count": 5,
  "warnings": []
}
```

## Sub-Skills

| Sub-skill            | Purpose                                                                  |
| -------------------- | ------------------------------------------------------------------------ |
| `ai-stance/template` | Generates AI_STANCE.md from scratch for a new repo                       |
| `ai-stance/audit`    | Reviews existing AI_STANCE.md for completeness and currency              |
| `ai-stance/diff`     | Compares two repos' stances to identify inconsistencies across the suite |
