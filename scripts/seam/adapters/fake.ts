import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { branchName, currentChange } from "../branch.ts";
import { GATES, SeamError } from "../contract.ts";
import type { ChangeStatus, GateRecord, GateStage, NextAction, SdlcEngine, Stage } from "../contract.ts";

const DIR = ".sdlc-fake";
const SLUG = /^[a-z0-9][a-z0-9-]*$/;

// Second engine, proving the seam is not morsadev-shaped. State is plain git:
// a gate is the file `.sdlc-fake/<slug>/<stage>.gate` (`<state> <email>`), read at HEAD,
// and its commit is the last one touching it. Unlike an empty trailer commit, a file
// survives `git merge --squash`.
// shortcut: the file is trusted as written (a hand-edited gate file passes); the real engine must not be.
export function createFakeEngine(cfg: { botIdentities?: string[] }, root: string): SdlcEngine {
  const bots = new Set((cfg.botIdentities ?? []).map((b) => b.toLowerCase()));
  const git = (...args: string[]): string =>
    execFileSync("git", args, { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
  const gitOr = (...args: string[]): string => {
    try {
      return git(...args);
    } catch {
      return "";
    }
  };
  const gateFile = (slug: string, stage: GateStage) => `${DIR}/${slug}/${stage}.gate`;
  const known = (slug: string) => SLUG.test(slug) && existsSync(join(root, DIR, slug));

  function record(slug: string, stage: GateStage): GateRecord {
    const [state, approver] = gitOr("show", `HEAD:${gateFile(slug, stage)}`).split(" ");
    if (state !== "approved" && state !== "rejected") return { state: "pending", approver: null, commit: null };
    return { state, approver: approver ?? null, commit: gitOr("log", "-1", "--format=%H", "--", gateFile(slug, stage)) || null };
  }

  function status(slug: string): ChangeStatus | null {
    if (!known(slug)) return null;
    const gates = Object.fromEntries(GATES.map((g) => [g, record(slug, g)])) as Record<GateStage, GateRecord>;
    const stage: Stage = GATES.find((g) => gates[g].state !== "approved") ?? "build";
    return { schema: 1, change: slug, stage, artifactsDir: `${DIR}/${slug}`, gates };
  }

  function decide(slug: string, stage: GateStage, state: "approved" | "rejected"): void {
    if (!known(slug)) throw new SeamError(`unknown change: ${slug}`, 2);
    const who = /<([^>]*)>/.exec(git("var", "GIT_AUTHOR_IDENT"))?.[1]?.toLowerCase() ?? "";
    if (bots.has(who)) throw new SeamError("approver is a bot", 1);
    if (state === "approved") {
      const author = gitOr("log", "-1", "--format=%ae", "--", `${DIR}/${slug}/${stage}.md`).toLowerCase();
      if (!author) throw new SeamError(`${slug}/${stage}.md is not committed`, 1);
      if (author === who) throw new SeamError("self-approval is off", 1);
    }
    const file = gateFile(slug, stage);
    const content = `${state} ${who}\n`;
    if (gitOr("show", `HEAD:${file}`) === content.trim()) return;
    writeFileSync(join(root, file), content);
    git("add", "--", file);
    git("commit", "-q", "-m", `chore(sdlc): ${state} ${slug}/${stage}`, "--", file);
  }

  return {
    name: "fake",
    version: () => "1",
    status,
    next(): NextAction {
      const change = currentChange(root, known);
      if (!change) {
        return { schema: 1, change: null, stage: null, action: `no change for branch ${branchName(root)}: run sdlc-seam new <slug> --title <title>` };
      }
      const st = status(change) as ChangeStatus;
      const action =
        st.stage === "build"
          ? "build, then ship"
          : `write ${st.stage}.md, commit it, then a human runs: sdlc-seam approve ${change} ${st.stage}`;
      return { schema: 1, change, stage: st.stage, action };
    },
    changesTouchedSince(base: string): string[] {
      const files = gitOr("diff", "--name-only", `${base}...HEAD`, "--", DIR).split("\n");
      return [...new Set(files.map((f) => f.split("/")[1]).filter((s): s is string => !!s))];
    },
    newChange(slug: string, title: string): string {
      if (!SLUG.test(slug)) throw new SeamError(`invalid slug: ${slug}`, 2);
      if (title.trim() === "") throw new SeamError("title is required", 2);
      if (known(slug)) throw new SeamError(`change exists: ${slug}`, 2);
      mkdirSync(join(root, DIR, slug), { recursive: true });
      for (const g of GATES) writeFileSync(join(root, DIR, slug, `${g}.md`), `# ${title}: ${g}\n`);
      return `${DIR}/${slug}`;
    },
    approve: (change, stage) => decide(change, stage, "approved"),
    reject: (change, stage) => decide(change, stage, "rejected"),
  };
}
