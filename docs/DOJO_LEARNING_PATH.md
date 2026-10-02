# Dojo Learning Path for uFawkesAI

> Use this when your real need is: "I am using uFawkesAI and want to grow from a good setup into a mature AI-assisted delivery practice."
>
> The uFawkesDojo curriculum has five belts and 20 modules covering the full DORA AI capability landscape. This repository implements seven capabilities directly; the Dojo helps you turn that foundation into team-level mastery.

This path is intentionally practical: it starts from your current level and points you to the template files to configure, the modules to study, and the belt assessment that proves you are ready to move up.

For the official dojo curriculum, start at <https://dojo.ufawkes.dev> and use the belt map there as the final authority.

---

## Pick the track that matches your starting point

| You are... | Best track | Expected effort |
| --- | --- | --- |
| New to AI-assisted development | Track A — White Belt → Yellow Belt → template adoption | 2–3 hours |
| Experienced dev but new to DORA and team-level workflow design | Track B — Team archetype → targeted belt modules → template sections in order | 4–6 hours |
| Platform engineer onboarding a team | Track C — Black Belt path + archetype customization | 6–8 hours |

---

## Track A: New to AI-assisted dev — White Belt → Yellow Belt → then use the template

### Prerequisites

- You can clone the repo, run the setup script, and open a branch.
- You are comfortable with basic Git and an editor.
- You want a stable starting point before expanding into deeper DORA practices.

### Estimated time

2–3 hours

### Recommended path

1. White Belt: learn the fundamentals of safe, intentional AI-assisted work.
   - Focus on issue quality, clear acceptance criteria, and small-batch delivery.
   - Study the repo's supporting files before customizing anything: `AGENTS.md`, `AI_STANCE.md`, and `docs/GOLDEN_PATH.md`.
2. Yellow Belt: convert the principles into a working process.
   - Use the template as your first real workflow instead of improvising your own standards.
3. Move from training into adoption.
   - Start using the repository's default issue template and the standard agent-ready pattern in `README.md`.

### Template files to configure at each stage

- Stage 1: `AGENTS.md`
  - Set your explicit AI stance and default working patterns.
- Stage 2: `AI_STANCE.md`
  - Confirm what AI is for, what it is not for, and the guardrails for your team.
- Stage 3: `docs/GOLDEN_PATH.md`
  - Define the exact flow from idea to deploy.
- Stage 4: `docs/PROMPT_LIBRARY.md`
  - Add your most common task prompts and reinforce the good defaults.
- Stage 5: `docs/METRICS.md`
  - Add a baseline measurement ritual so progress is visible.

### How to validate mastery

Use the Dojo's belt assessment at the White and Yellow levels:

- White Belt assessment: can you explain the workflow from issue to pull request without improvising?
- Yellow Belt assessment: can you open a small issue, implement it with the template, and produce a clean, reviewable PR using the repo's standard flow?

If the answer is no, stay in the template and repeat the same flow on a small feature before moving forward.

---

## Track B: Experienced dev, new to DORA — Read `docs/TEAM_ARCHETYPE.md` → targeted belt modules → implement template sections in order

### Prerequisites

- You already have a strong coding workflow.
- You are learning DORA and team-level AI adoption rather than basic usage.
- You want the template to support the right operating model, not just the fastest prompts.

### Estimated time

4–6 hours

### Recommended path

1. Read `docs/TEAM_ARCHETYPE.md` first.
   - This is the “why” behind the template and the fastest way to determine which capabilities matter most for your team.
2. Identify your archetype and the weakest DORA AI capabilities.
3. Study the targeted Dojo belt modules that match those weaknesses.
4. Implement template sections in order, not all at once.

### Template files to configure in order

1. `docs/TEAM_ARCHETYPE.md`
   - Use the self-assessment to identify your current maturity and bottlenecks.
2. `docs/METRICS.md`
   - Add the metrics ritual your team will actually review.
3. `docs/VALUE_STREAM_MAP.md`
   - Document the current flow and identify bottlenecks.
4. `docs/RUNBOOKS.md`
   - Capture emergency and operational playbooks.
5. `docs/CHANGE_IMPACT_MAP.md`
   - Clarify which files and decisions have the highest blast radius.
6. `AGENTS.md`
   - Tighten the AI policy and operating constraints around the core workflow.
7. `docs/GOLDEN_PATH.md`
   - Write the production path for your own repo after the team-level choices are clear.

### How to validate mastery

Use the Dojo belt assessment that matches your archetype:

- Can you explain which archetype you are in and why?
- Can you name the two or three weakest DORA AI capabilities for that archetype?
- Can you implement the template sections in priority order and show the resulting workflow to a teammate?
- Can you update the metrics and value stream without reintroducing chaos?

This track is the bridge between “I know how to code” and “I know how to lead an AI-assisted team without creating AI-induced instability.”

---

## Track C: Platform engineer onboarding a team — All Black Belt modules + customize each template section per DORA archetype

### Prerequisites

- You are responsible for platform standards, team enablement, or repository-level AI operating model design.
- You can evaluate architecture, process, automation, and onboarding at the team level.
- You are comfortable customizing the template instead of adopting it as-is.

### Estimated time

6–8 hours

### Recommended path

1. Complete the full Black Belt Dojo sequence.
   - This is the path for platform-level enabling, not just individual productivity.
2. Use the archetype assessment to tailor every template section.
3. Customize the repo for the archetypes your teams are actually in, not the archetype you wish you had.

### Template sections to customize by archetype

- `AGENTS.md`
  - Make policies strict enough for the team's maturity level.
- `docs/TEAM_ARCHETYPE.md`
  - Capture the current team reality and review cadence.
- `docs/METRICS.md`
  - Tune the signals to the team's actual bottlenecks.
- `docs/VALUE_STREAM_MAP.md`
  - Adjust the flow to fit the delivery structure your team really uses.
- `docs/RUNBOOKS.md`
  - Put operational recovery and review loops in a repeatable place.
- `docs/CHANGE_IMPACT_MAP.md`
  - Define ownership and blast radius for high-risk work.
- `docs/GOLDEN_PATH.md`
  - Standardize the delivery flow everyone is expected to operate within.
- `.github/instructions/` and related repository automation
  - Apply the same standards consistently across multiple team workflows.

### Archetype-driven customization guide

- Archetype 1 or 2: fix stability and observability before accelerating throughput.
- Archetype 3: streamline process and reduce friction before broadening AI use.
- Archetype 4: improve deploy automation and delivery cadence before more advanced AI workflow changes.
- Archetype 5 or 6: keep the template disciplined and add review guardrails as AI volume increases.
- Archetype 7: keep the system healthy while scaling throughput and metrics visibility.

### How to validate mastery

Use the Black Belt assessment as a team-level proof:

- Can your team explain its current archetype and why it fits there?
- Can you show a working template customization for each critical section?
- Can you prove the adoption path from single repo to team practice without breaking delivery consistency?
- Can you explain which DORA AI capability gaps were intentionally prioritized first and which were deferred?

This is the path for people who are not just using the template — they are operationalizing it as a repeatable team platform.

---

## Fast recommendation by scenario

- “I just want to get productive safely.” → Track A
- “I already code, but I need the system behind AI to be healthier.” → Track B
- “I am onboarding a team or standards layer.” → Track C

---

## Suggested next actions

1. Start with `docs/TEAM_ARCHETYPE.md` if you are deciding where to focus.
2. Use `README.md` as the quick-start entry point.
3. Use the Dojo path as the deepening loop once the template is stable.

Keep the sequence simple: establish the right operating model, then scale the AI workflow. The Dojo is most useful when it turns the template from a starter pack into a repeatable mastery path.
