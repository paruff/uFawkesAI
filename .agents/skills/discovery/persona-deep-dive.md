---
name: discovery/persona-deep-dive
description: "Extended persona research when the primary persona for a change is unclear or when two personas appear equally important. Produces a persona selection rationale that becomes part of the discovery brief. Use before writing a JTBD statement if the persona is ambiguous."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: discovery
---

# Sub-Skill: Discovery — Persona Deep Dive

> **Load trigger:** `"load discovery/persona-deep-dive skill"` > **DORA:** AI Capability 6 (User-centric focus)
> **Token cost:** Low
> **When to use:** Persona is ambiguous, or two personas have equally strong claims.

## Purpose

Resolve persona ambiguity before writing a JTBD statement. An ambiguous persona
produces an ambiguous JTBD, which produces an untestable acceptance criterion, which
produces a feature nobody actually needed. Spend 10 minutes here to avoid that cascade.

## The Ambiguity Signals

Run this sub-skill when any of these are true:

- The proposed change description uses "users" generically without naming a role
- Two different personas would use the same feature in fundamentally different ways
- A previous release was under-adopted — the persona assumption may have been wrong
- The change spans multiple stack repos (different stacks have different primary personas)

## Persona Disambiguation Protocol

### Step 1 — List all personas who touch this change

From the discovery skill's Persona Reference Table, identify every persona who
would interact with this change — not just benefit from it. Include:

- Who triggers the change (initiates the action)
- Who is affected by the change (receives the outcome)
- Who configures or maintains the change (ongoing responsibility)

For most uFawkes\* changes, the triggering persona is the most important one.

### Step 2 — Apply the stakes test

For each candidate persona, answer:

| Question                                          | Answer    |
| ------------------------------------------------- | --------- |
| If this change doesn't ship, who is most blocked? | [persona] |
| If this change ships wrong, who is most harmed?   | [persona] |
| Who will file an issue if this breaks?            | [persona] |
| Who has the clearest definition of "done"?        | [persona] |

The persona who answers the most of these questions is the primary persona.

### Step 3 — Check GitHub issue history

```bash
# Find issues filed by users that relate to this area
gh issue list --repo paruff/REPO_NAME --state all --label "user-feedback" \
  --json number,title,body,labels \
  --jq '.[] | {number, title, body: .body[0:200]}'

# Look for patterns: are issues about platform complexity (platform-engineer persona)
# or about golden path gaps (product-engineer persona)?
```

### Step 4 — Check platform-feedback history

If a quarterly platform-feedback survey has been run, check the Q2 "hardest part"
responses for this area. The persona who reported friction is the primary persona.

### Step 5 — State the selection rationale

Write one paragraph:

- Primary persona selected: [name]
- Why: [the stakes-test answer that was clearest]
- Secondary persona: [name] — their needs will be addressed via [how, e.g., "configuration option in v0.2"]
- Conflicting needs: [if any — how the conflict is resolved]

Add this paragraph to `discovery-brief.md` under a "Persona Selection" section.

## Common Ambiguity Patterns and Resolutions

| Ambiguity                                              | Resolution                                                                                                                                                               |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "Is this for platform-engineer or product-engineer?"   | Platform-engineer if it changes how the IDP works; product-engineer if it changes what a team can build with it                                                          |
| "Is this a Dojo learner change or platform change?"    | Dojo learner if the primary outcome is learning; platform change if the primary outcome is a running system                                                              |
| "Is this for current users or new users?"              | Current users if it fixes a pain point; new users if it enables adoption. Current users win if unsure — don't break what works to attract people who haven't arrived yet |
| "Is this for fawkes itself or for teams using fawkes?" | fawkes itself = platform-engineer persona; teams using fawkes = product-engineer or team-lead persona                                                                    |

## Output

Append to `discovery-brief.md`:

```markdown
## Persona Selection (from persona-deep-dive sub-skill)

**Candidates considered:** platform-engineer, product-engineer
**Primary persona selected:** platform-engineer
**Selection rationale:** The change modifies how the CI pipeline runs — a concern
the platform-engineer configures, not a concern the product-engineer experiences
directly. Product-engineers are secondary; they benefit from the change but don't
trigger it or define "done."
**Secondary persona:** product-engineer — their need (faster feedback) addressed
via the deployment frequency metric improvement this change enables.
**Conflicting needs:** None identified.
```

## Output Format

```json
{
  "sub-skill": "discovery/persona-deep-dive",
  "candidates_considered": ["platform-engineer", "product-engineer"],
  "primary_persona": "platform-engineer",
  "selection_confidence": "high | medium | low",
  "selection_rationale": "string",
  "secondary_persona": "product-engineer",
  "conflict_identified": false,
  "discovery_brief_updated": true
}
```
