# Golden Path — [PROJECT NAME]

> DORA 2025 (PLAT-02): "Identify the golden path for the most common workflow and build
> just enough to make that specific journey demonstrably better. Developer independence
> resulted in a 5% productivity improvement."
>
> This document is the single lowest-friction route from idea to deployed feature.
> Every agent, every PM, every contributor follows this path.
> Off-path decisions require explicit human judgment.

---

## The Path at a Glance

```
1. SPEC     → PM writes issue with feature template
2. BRANCH   → git checkout -b feat/ISSUE-ID-description
3. TEST     → Write failing test → commit (RED)
4. IMPLEMENT → Prompt Copilot with AC + failing test → commit (GREEN)
5. VERIFY   → npm run preflight
6. PR       → Draft PR with AI-Assisted Review Block
7. CI GATE  → Automated gates must pass
8. REVIEW   → @review-agent pre-screen → human review (< 24h target)
9. MERGE    → Squash merge with conventional commit
10. DEPLOY  → Automated deploy on merge
```

---

## Step-by-Step with Commands

### Step 1 — Spec (PM)
Create a GitHub issue using the **Feature** issue template.

Write acceptance criteria specific enough that each one becomes either:
- A unit test (`it('returns X when Y')`)
- A BDD scenario (`Given / When / Then`)

**If you cannot write a test for an AC, the AC is too vague. Rewrite it.**

---

### Step 2 — Branch
```bash
git checkout main && git pull
git checkout -b feat/ISSUE-ID-short-description
# Example: feat/42-deposit-validation
```

Naming: `feat/`, `fix/`, `docs/`, `chore/` + issue number + description.

---

### Step 3 — Failing Test First (DORA Cap 5 — Shift Left)

Write the test that describes the desired behaviour. Commit while it's failing.

```bash
# Write your test in tests/unit/ or tests/e2e/
npm test  # Should fail — that's correct

git add tests/
git commit -m "test(scope): failing test for [ISSUE-ID] — [what it tests]"
```

**Why commit while red?** It proves the test is actually testing something.
A test that passes before implementation is testing nothing.

---

### Step 4 — Implement with Copilot

Open the issue, open the failing test, and prompt Copilot:

```
Implement [function/feature] to make this failing test pass.

Constraints from .github/copilot-instructions.md:
- [paste the 5 architecture rules]

The failing test is:
[paste test]

Read src/types/index.ts and docs/API_SURFACE.md before writing code.
Use the prompt template from docs/PROMPT_LIBRARY.md → [relevant category].
```

Commit when tests go green:
```bash
npm test  # Should pass now
git commit -m "feat(scope): implement [ISSUE-ID] — [what was built]"
```

---

### Step 5 — Preflight Check (DORA Cap 6 — Fast Feedback)

```bash
npm run preflight  # lint + typecheck + tests — must all pass

# If it fails: fix here, not in CI. CI failure = wasted cycle time.
```

Do not open a PR until preflight passes locally.

---

### Step 6 — Open Draft PR

```bash
git push -u origin feat/ISSUE-ID-description
# Open PR on GitHub → set to Draft
# Select: PULL_REQUEST_TEMPLATE.md
```

Fill in every section of the AI-Assisted Review Block:
```
@review-agent Please pre-screen this PR against .github/copilot-instructions.md
```

---

### Step 7 — CI Gates Pass

The CI pipeline runs automatically:
- 🔢 PR size check (< 400 lines or `large-pr-approved` label)
- 🔍 Lint
- 🔷 TypeScript
- 🧪 Tests + coverage
- 🏗️ Architecture boundaries

If any gate fails: fix locally, push again. Do not ask reviewers to look at a failing PR.

---

### Step 8 — Human Review (DORA 2025 — Review Speed)

Mark PR as Ready for Review. Tag the reviewer.

**Target: reviewed within 24 hours.**
DORA 2025: "Teams with shorter code review times have 50% better delivery performance."

Reviewer checklist:
- [ ] AI-Assisted Review Block is complete
- [ ] Architecture boundaries respected
- [ ] Tests actually test the failure cases
- [ ] No judgment calls left unaddressed by the author

---

### Step 9 — Merge

Squash merge with conventional commit message:
```
feat(scope): [description] (#ISSUE-NUMBER)
```

Delete the feature branch after merge.

---

### Step 10 — Deploy

[PLACEHOLDER — describe your deploy trigger. Example:]

Merge to `main` triggers automatic deployment via [EAS Build / Expo OTA / GitHub Actions].
A deploy marker is created in Sentry for correlation.

Check Sentry for any error spike in the 30 minutes after deploy.
If spike detected: see `docs/RUNBOOKS.md` → Emergency Rollback.

---

## Off-Path Decisions (Require Human Judgment)

These situations require the PM and a human developer to discuss before assigning to an agent:

| Situation | Why it's off-path |
|---|---|
| Adding a new npm dependency | Security review, bundle size, license check |
| Database schema change | Migration strategy, backward compatibility |
| Authentication flow change | Security-critical, cannot be fully automated |
| New architecture layer or pattern | Structural decision affecting all future agents |
| Feature touching > 5 files | Break into multiple issues first |
| Removing a known limitation | Verify the root cause is actually fixed, not just hidden |

---

## Quick Reference

```bash
npm run preflight     # lint + typecheck + tests (run before every push)
npm run pr-ready      # preflight + "ready to push" message
npm run metrics       # weekly metrics summary (rework rate, coverage, etc.)
```
