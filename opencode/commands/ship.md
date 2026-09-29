---
description: Run pre-commit, fix issues, commit, push, and open a PR
agent: build
---

Complete the end-of-feature shipping workflow. Follow the steps in order,
stopping and reporting immediately if any step fails irrecoverably.

## Step 1: Stage (with exclusions)

Stage the deliverable: `git add -A`, then unstage anything excluded —
`.env*`, credentials/keys/tokens, `*.db`, `.DS_Store`, `node_modules`,
scratch/prototype dirs not part of the change. If a secret appears in the
diff, STOP and tell the user.

Staging comes first because lefthook's pre-commit hook runs against
**staged** files.

## Step 2: Pre-commit validation

Detect the repo's hook system:

- `.lefthook.yml` present → `npx lefthook run pre-commit`
- `.pre-commit-config.yaml` present → `pre-commit run --all-files`
- neither → note "no hook gate" and continue to Step 4

## Step 3: Fix issues autonomously

If pre-commit failed, analyze the output:

- **Auto-fixable** (formatting, lint, whitespace, imports): a hook may have
  rewritten files — `git add -A` again and re-run. Loop up to 3 times.
- **Requires code changes** (tests, typecheck, logic): fix, stage, re-run.
  Loop up to 3 times.
- **Non-converging** after 3 attempts: stop and report the remaining errors
  with a clear summary.

Only proceed once pre-commit passes cleanly (or Step 2 found no hook gate).

## Step 4: Sanity check

- `git status` and `git diff --staged`
- `git log --oneline -5` — match the existing commit style
- `git branch --show-current` — if `main` or `master`, STOP and warn the user

## Step 5: Commit

Conventional Commits: `<type>(<scope>): <summary>`, first line ≤ 72
characters, imperative mood, scope matching repo history (e.g. `feat(review):`,
`fix(srs):`, `chore(opencode):`, `content(vocab):`). Add a body for
non-trivial changes.

If the commit fails because a hook auto-fixed files, `git add -u` and retry
once.

## Step 6: Push

- No upstream → `git push -u origin "$(git branch --show-current)"`
- Otherwise → `git push`

Never pass `--no-verify`: this repo's pre-push hook runs content validation
and the unit suite and may take minutes — that is the gate, let it run. If
pre-push fails, treat it like Step 3 (fix → re-push, max 3 attempts).

## Step 7: Open (or update) the PR

- `gh pr list --head "$(git branch --show-current)" --state open` — if a PR
  exists, update it (`gh pr edit <n> --title … --body …`).
- Otherwise:

```bash
gh pr create --base main --title "<concise title>" --body "$(cat <<'EOF'
## Summary
- <2-4 bullets: what changed and why>

## Test plan
- [ ] <how to verify the changes>
EOF
)"
```

## Step 8: Report

- Pre-commit status (passed, or fixed after N attempts)
- Commit hash and message
- Branch name
- PR URL (or "existing PR updated")
