# Skill: Language — TypeScript

> **Load trigger:** `"load lang-typescript skill"`
> **Stack:** TypeScript, Node.js, ESLint, tsc, Jest/Vitest, npm
> **Token cost:** Low

## Toolchain Reference

| Gate      | Tool              | Command                 | Config file                            |
| --------- | ----------------- | ----------------------- | -------------------------------------- |
| Lint      | ESLint            | `npm run lint`          | `.eslintrc.js` or `eslint.config.js`   |
| Typecheck | tsc               | `npm run typecheck`     | `tsconfig.json`                        |
| Test      | Jest or Vitest    | `npm run test`          | `jest.config.ts` or `vitest.config.ts` |
| Coverage  | Jest `--coverage` | `npm run test:coverage` | `jest.config.ts`                       |
| Preflight | custom            | `npm run preflight`     | `scripts/preflight.sh`                 |

## File Layout Convention

```
src/
  types/index.ts        ← all shared types and interfaces
  services/             ← business logic, no UI dependencies
  utils/                ← pure functions, no side effects
  screens/ or pages/    ← UI layer only
tests/
  services/             ← mirrors src/services/
  utils/                ← mirrors src/utils/
```

## CI Gate Commands (ci-quality.yml)

```yaml
- name: Lint
  run: npm ci && npm run lint

- name: Typecheck
  run: npm run typecheck

- name: Test with coverage
  run: npm run test:coverage
  env:
    CI: true

- name: Coverage threshold
  run: |
    COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage $COVERAGE% is below 80% threshold"
      exit 1
    fi
```

## Type Standards

- No `any` in service or utility functions
- Catch blocks: `catch (error: unknown)` — narrow before use
- All external API responses typed with Zod or explicit interface
- No inline type definitions in function signatures — define in `src/types/index.ts`

## OTEL SDK (for obs-agent)

```bash
npm install @opentelemetry/sdk-node @opentelemetry/exporter-trace-otlp-http
```

Init pattern: `src/instrumentation.ts` — imported before all other imports in entry point.

## Node Version

Node 20 LTS. Pin in `.nvmrc` and `engines` field in `package.json`.
GitHub Actions: `uses: actions/setup-node@v4` with `node-version: '20'`.
