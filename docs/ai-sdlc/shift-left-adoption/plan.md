# Plan: adopt uFawkesPipe's shared shift-left hooks

**Traces to:** uFawkes.dev [`docs/ai-sdlc/shift-left/spec.md`](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/shift-left/spec.md)
(R1–R6, R9) and its [plan](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/shift-left/plan.md),
phase C2 | **Status:** In progress

uFawkesPipe publishes the suite's shift-left hooks and tools once, by tag.
This repo pins that tag and holds one file of its own, `scripts/shift-left.sh`,
which runs the tools that aren't hooks (doctor, agent gate, triage,
`require-tool`) from the same pinned clone.

| Step | What                                                                                                                  |
| ---- | --------------------------------------------------------------------------------------------------------------------- |
| C2a  | CI calls uFawkesPipe's reusable Pre-flight (both hook stages, the commit-msg hook), pinned by SHA                     |
| C2b  | The shared hooks (parity, semgrep, Trivy, stamps), actionlint and schema hooks, `require-tool` for tool-backed hooks, `.shift-left.yml`, the doctor at session start, the agent gate, the devcontainer, `make doctor` |
| F    | Type check (#192, owner decision 2026-10-08): `tsc --noEmit` on the OpenCode plugin under the strict `tsconfig.json` (hook `tsc-plugin`, no npm install) and mypy at default strictness on the Python templates. CI's 🔷 TypeScript job now really runs `tsc`; it used to skip it. |

## Verification Strategy

| Check                                   | How                                                                                       |
| --------------------------------------- | ----------------------------------------------------------------------------------------- |
| Every hook runs in CI or says why not   | `bash scripts/shift-left.sh check-shift-left-parity` (also a hook): 42 hooks, 39 in CI    |
| CI's two stages pass                     | Both stages run locally as Pre-flight runs them (`SKIP` from `.shift-left.yml`), then CI |
| The checks actually run in a clone      | `make doctor`                                                                             |
| Nothing slips back                       | uFawkes.dev's `/status/` matrix, rebuilt daily                                            |
| Type checks catch errors (F)             | A planted type error fails `pre-commit run tsc-plugin` (also with no `.opencode/node_modules`) and `pre-commit run mypy`; the 🔷 TypeScript job fails unless its log shows `PASS  tsc --noEmit` |
