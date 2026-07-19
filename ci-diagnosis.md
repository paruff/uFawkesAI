# CI Diagnosis — PR #57

## Failure Summary

| Item                    | Value                                                                |
| ----------------------- | -------------------------------------------------------------------- |
| **PR**                  | #57 — refactor(ci): migrate reusable workflows to uFawkesPipe@v1.0.0 |
| **Failing Jobs**        | `✈️ Pre-flight / Pre-flight Checks` in both CI and CI Quality Gate   |
| **Root Cause Category** | Code                                                                 |
| **Confidence**          | HIGH                                                                 |

## Evidence

### Failure 1: Pre-commit hooks failing on updated config

The PR updated `.pre-commit-config.yaml` to add Ruff, ruff-format, markdownlint, Prettier 4.0, yamllint, gitleaks, detect-secrets, and a commit-msg hook. The existing codebase did not comply with the new formatting rules, causing pre-commit hooks (ruff, ruff-format, markdownlint, prettier) to auto-fix files but exit with failure (exit code 1).

```
ruff.....................................................................Failed
- hook id: ruff
- files were modified by this hook
Found 9 errors (9 fixed, 0 remaining).

ruff-format..............................................................Failed
- hook id: ruff-format
- files were modified by this hook
6 files reformatted, 2 files left unchanged

markdownlint.............................................................Failed
- hook id: markdownlint
- files were modified by this hook

prettier.................................................................Failed
- hook id: prettier
- files were modified by this hook
```

### Failure 2: Shellcheck warnings in existing shell scripts

The uFawkesPipe reusable preflight workflow runs shellcheck on all `.sh` files. Two pre-existing scripts had SC2155 warnings (`export` combined with assignment).

```
In ./scripts/agent-skill-graph.sh line 23:
export SNAPSHOT_UTC="$(date -u +"%Y-%m-%d %H:%M:%SZ")"
       ^----------^ SC2155 (warning): Declare and assign separately to avoid masking return values.
```

### Failure 3: Merge commit not following Conventional Commits

The Copilot-created merge commit `bd79bd3` had the message `merge(main): resolve modify/delete conflicts — keep reusable workflow deletions` which does not match the conventional commit pattern `^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?: .{1,72}$`.

### Failure 4: Merge conflict with reusable-lint.yml

The PR branch deletes `.github/workflows/reusable-lint.yml` but `main` has modifications to it (setup-node v6→v7 bump). This creates a modify/delete conflict.

### Failure 5: PR size check (854 lines vs 400 limit)

The PR exceeds the 400-line size limit, but this was resolved by applying the `large-pr-approved` label.

## Proposed Fix

1. Run `pre-commit run --all-files` to auto-format all files to comply with the new pre-commit config
2. Fix shellcheck SC2155 warnings by separating export from assignment
3. Rewrite the merge commit message to use `chore(merge):` prefix
4. Resolve merge conflict by keeping the deletion of reusable-lint.yml
5. Apply `large-pr-approved` label to bypass PR size check
