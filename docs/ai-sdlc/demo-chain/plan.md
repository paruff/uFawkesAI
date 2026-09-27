# Design: Demo greeting

Implements `docs/ai-sdlc/demo-chain/spec.md`.

## Implementation Sequence

1. Add `src/demo/hello.ts` — depends on: none

## Verification Strategy

| AC | How it is proven | test_type | Command / CI job |
| -- | ---------------- | --------- | ---------------- |
| AC-01 | assert `hello("ada") === "hello ada"` | unit | `npm test` |
