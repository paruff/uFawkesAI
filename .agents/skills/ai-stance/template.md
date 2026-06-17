---
name: ai-stance/template
description: "Generate AI_STANCE.md from scratch for a repo that doesn't have one. Use when onboarding any uFawkes* repo to the suite. Produces a fully populated, review-ready document in one session."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: ai-stance
---

# Sub-Skill: AI Stance — Template

> **Load trigger:** `"load ai-stance/template skill"` > **DORA:** AI Capability 1 (Clear and communicated AI stance)
> **Token cost:** Low
> **When to use:** Repo has no `AI_STANCE.md`. Run once per repo.

## Purpose

Generate a complete, populated `AI_STANCE.md` for a new repo. Asks four questions,
fills the three-bucket framework, and writes the file. Total time: under 15 minutes.

## Inputs Required

Before generating, confirm:

| Input                                      | Where to find it                             | Required? |
| ------------------------------------------ | -------------------------------------------- | --------- |
| Repo name                                  | Current working directory / git remote       | ✅        |
| Primary persona using this repo            | Persona reference table in `discovery` skill | ✅        |
| Any repo-specific prohibited uses          | Human judgment call                          | ✅        |
| Any tools NOT in the suite defaults        | Human input                                  | Optional  |
| Compliance requirements (SOC2, GDPR, etc.) | Project context                              | Optional  |

## Generation Steps

### Step 1 — Confirm suite defaults apply

Check whether the repo needs any deviation from the suite-wide defaults in the
parent `ai-stance` skill:

```
Suite defaults cover:
✅ opencode, graphify [confirm variant], ponytail, Claude Sonnet 4.6
✅ Standard prohibited list (PII, secrets, bypass pre-commit/branch protection)
✅ Standard guardrails (human review before merge, session logging)

Does this repo need additions? Common repo-specific additions:
- uFawkesObs: "Prohibited: AI-generated Prometheus alerting rules without human review
  (alerts trigger pager — false positives have real cost)"
- uFawkesSec: "Prohibited: AI-generated OPA/Kyverno policies without security review"
- uFawkes.dev: "Permitted-with-guardrails: AI-generated Dojo content must include
  disclosure to learners that AI assisted in authoring"
```

### Step 2 — Write the file

```bash
# Confirm repo name
REPO=$(basename $(git rev-parse --show-toplevel))
TODAY=$(date +%Y-%m-%d)
NEXT_REVIEW=$(date -d "+90 days" +%Y-%m-%d 2>/dev/null || date -v+90d +%Y-%m-%d)

cat > AI_STANCE.md << 'STANCE'
# AI Stance — REPO_PLACEHOLDER

> Last reviewed: TODAY_PLACEHOLDER
> Next review due: NEXT_PLACEHOLDER (quarterly)
> Owner: paruff
> Suite: uFawkesAI

## Expectation of Use

AI-assisted development is expected in this repo. We use AI tools to clear bottlenecks
in the product lifecycle — not to replace human judgment on architecture, security,
and user research decisions. All AI assistance is logged via opencode session history.

## Organizational Support

- Permitted tools: listed below
- Skill suite: uFawkesAI `.agents/skills/` — load relevant skills before each session
- Context corpus: maintained via context-engineering skill (load at session start)
- Questions or policy concerns: file a GitHub issue with label `ai-policy`
- Policy reviews: quarterly — see ai-policy-lifecycle skill

## Permitted Tools

| Tool | Model / version | Scope |
|---|---|---|
| opencode | latest stable | Primary agentic development tool |
| Claude | claude-sonnet-4-6 | Skill authoring, code review, content generation |
| graphify | [CONFIRM_VARIANT] | Context corpus building — verify variant before use |
| ponytail | latest stable | YAGNI enforcement in all agent sessions |
| GitHub Copilot | current | IDE code completion |

## Three-Bucket Classification

### Prohibited
- Sending PII, credentials, or proprietary infrastructure configs to public AI models
- Committing AI-generated code without pre-commit hooks passing
- Bypassing branch protection rules on AI guidance
- AI-generated security policy or compliance docs without qualified human review
- [REPO_SPECIFIC_PROHIBITED — add any repo-specific items here or delete this line]

### Permitted with Guardrails

| Use | Guardrail |
|---|---|
| AI-generated code merged to main | Human review required; at least one test covering the change |
| AI-assisted spec / design documents | discovery-brief.md must exist first |
| Agent sessions modifying infrastructure | j-curve-navigation pre-flight check must pass |
| AI-generated release notes | Human review before publishing |
| AI-generated content in Dojo modules | Disclose to learners that AI assisted in authoring |
| opencode sessions in this repo | Load AGENTS.md and relevant skills at session start |
| graphify corpus built from this repo | Corpus must not include files containing secrets or PII |

### Allowed
- AI-assisted code completion for any file not in the Prohibited scope
- AI-generated first drafts of blog posts, dev.to articles, LinkedIn posts
- AI-assisted GitHub issue triage and labeling
- AI-generated test stubs (human completes and verifies)
- Asking AI tools to explain existing code or documentation

## Role Applicability

This stance applies to: **human contributors AND AI agents** (opencode sessions,
GitHub Actions opencode workflow, any automated agent invocation in this repo).

Agents must:
1. Load `ai-stance` skill and verify this document exists before beginning work
2. Log the session via opencode session history
3. Flag any action that would fall into the Prohibited bucket and halt — do not
   proceed without explicit human authorization for prohibited actions
STANCE

# Substitute placeholders
sed -i "s/REPO_PLACEHOLDER/${REPO}/g" AI_STANCE.md
sed -i "s/TODAY_PLACEHOLDER/${TODAY}/g" AI_STANCE.md
sed -i "s/NEXT_PLACEHOLDER/${NEXT_REVIEW}/g" AI_STANCE.md

echo "✅ AI_STANCE.md generated for ${REPO}"
echo "⚠  Review and update:"
echo "   - [CONFIRM_VARIANT]: Replace with actual graphify variant"
echo "   - [REPO_SPECIFIC_PROHIBITED]: Add repo-specific prohibitions or delete the line"
```

### Step 3 — Verify with audit sub-skill

After generating, immediately run the audit sub-skill to confirm all four clarity
dimensions are present:

```
Load trigger: "load ai-stance/audit skill"
```

## Output Format

```json
{
  "sub-skill": "ai-stance/template",
  "repo": "paruff/REPO_NAME",
  "file_created": "AI_STANCE.md",
  "placeholders_remaining": ["CONFIRM_VARIANT"],
  "repo_specific_items_needed": true,
  "audit_recommended": true
}
```
