# Specification — AWS AI-DLC as an Opt-In Tool in the CDE Image

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 1

## Requirements

**R1 — Pinned and verified.** `aidlc` is installed in the `ai` variant from
`images/devsecops/tools.lock.json` at an exact version, with a SHA-256 per
arch (amd64 → `linux-x64`, arm64 → `linux-arm64`; glibc builds, not musl).
The hashes must appear in the release's `checksums.txt`, which
`scripts/image-lock-refresh.sh` already checks. No `curl | sh` at build time.

**R2 — Works offline.** In a fresh git repo inside the built image, with
`--network none`, `aidlc --version` prints the locked version and
`aidlc config --harness claude --dry-run` succeeds. If the dry run needs the
harness archive (`aidlc-runtime-<version>.tar.gz`), the image ships that too,
pinned and verified the same way (D1).

**R3 — Not configured by default.** The image and the template contain no
AI-DLC project files: no `aidlc/` folder, and no AI-DLC entries in
`.claude/`, `.opencode/`, `AGENTS.md` or `.gitignore`. The binary does
nothing until a user runs `aidlc config` in their own repo.

**R4 — Kept current.** `scripts/image-lock-bump.sh` picks up new stable
AI-DLC releases through the entry's `source` (`awslabs/aidlc-workflows`, tag
`v{version}`), with no AI-DLC-specific code. Previews
(`x.y.z-preview.*`) are never selected.

**R5 — Within budget.** The `ai` and `devcontainer` images pass
`images/devsecops/scan.sh`, and their cold and warm starts stay inside the
`benchmark` gate (10% and 50 ms over `benchmarks/baseline.json`).

**R6 — Documented opt-in.** `docs/DEVCONTAINER.md` gets a short section:
what AI-DLC is, that it's a second lifecycle beside the artifact chain, and
the opt-in sequence `aidlc config --harness <claude|opencode> --dry-run`,
then `aidlc config`, then `aidlc doctor`. It says which files the run will
write and that `AI_STANCE.md` treats changes to `.claude/` and `.opencode/`
as needing human sign-off.

**R7 — Evidence from a real run.** A repo made with "Use this template" from
the built image runs `aidlc config --harness claude` and one small `/aidlc`
task. The record (on the issue) lists every file written, the hooks added to
`.claude/settings.json`, the network calls made besides the model
provider's, wall time and token cost, and whether
`scripts/check-artifact-chain.sh` still passes.

## Decisions

**D1 — Install shape (settled in plan step 1).** Use a single `format:
binary` lock entry if R2 passes with the binary alone. Otherwise run the
upstream `install.sh --version <v> --from <dir> --offline --yes` against
assets downloaded and hash-checked from the lock, with `AIDLC_INSTALL_ROOT`
and `AIDLC_BIN_DIR` set to image paths, so upstream's own verification also
runs. Use the first that passes R1 and R2; record which one in this spec.

**D2 — Lifecycle relationship (after R7, not in this spec).** Choose one:
(a) AI-DLC stays a separate, opt-in tool; (b) AI-DLC stages produce
`docs/ai-sdlc/<feature>/{intent,spec,plan}.md` that the gate accepts;
(c) AI-DLC becomes the template's lifecycle. Default (a). Choosing (b) or
(c) needs its own intent, because it changes `AGENTS.md`, the agents and
the gate.

## Acceptance criteria

1. `verify-tools.sh ai` reports `aidlc` at its locked version (R1).
2. The R2 commands pass under `--network none` in the built `ai` image.
3. A grep of the built image's home folder and the template tree finds no
   AI-DLC project files (R3).
4. `scripts/image-lock-bump.sh --dry-run` lists `aidlc` and proposes no
   preview (R4).
5. `scan.sh` passes and the release `benchmark` job stays green (R5).
6. The R7 record is posted, and D2 is filed as a decision issue.

## Risks

- **Fast upstream cadence** (minor releases weekly): the weekly lock bump
  absorbs it, and the pin means nothing moves without a reviewed PR.
- **Hooks pile up** when a user opts in: AI-DLC's hooks run beside
  `ai-sdlc-hooks.ts` and the shift-left gate. R7 measures it before anyone
  recommends it.
- **Two lifecycles drift** if a team runs both: R6 says so up front, and D2
  settles it.
- **Third-party hooks in governed folders:** opting in is a per-repo human
  decision, never an agent's (R3, R6).
