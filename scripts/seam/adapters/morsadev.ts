import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { branchName, currentChange } from "../branch.ts";
import { GATES, SeamError } from "../contract.ts";
import type {
  ChangeStatus,
  GateRecord,
  GateStage,
  NextAction,
  SdlcEngine,
  Stage,
} from "../contract.ts";

// The only file that names `sdlc` commands or the `changes/` layout (spec R2.3).
const CHANGES = "changes";
const SLUG = /^[a-z0-9][a-z0-9-]*$/;
const PKG = join(import.meta.dirname, "../../../node_modules/@morsadev/sdlc");
const FILE: Record<GateStage, string> = {
  intent: "intent.md",
  spec: "spec.md",
  plan: "plan.md",
};

interface Row {
  change: string;
  slug: string;
  title: string;
  statuses: string;
}

// shortcut: needs the engine installed next to this repo's scripts/ (npm ci); an engine elsewhere is not found.
export function createMorsadevEngine(
  cfg: { botIdentities?: string[] },
  root: string,
): SdlcEngine {
  const bin = join(PKG, "dist/sdlc.mjs");
  if (!existsSync(bin))
    throw new SeamError("engine morsadev not installed: run npm ci", 2);
  const bots = new Set((cfg.botIdentities ?? []).map((b) => b.toLowerCase()));
  const git = (...args: string[]): string =>
    execFileSync("git", args, {
      cwd: root,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim();
  const gitOr = (...args: string[]): string => {
    try {
      return git(...args);
    } catch {
      return "";
    }
  };
  const who = (): string =>
    /<([^>]*)>/.exec(git("var", "GIT_AUTHOR_IDENT"))?.[1]?.toLowerCase() ?? "";

  // The engine reads identity from git config, not GIT_AUTHOR_*; hand it the session's identity.
  // The name is the email so two people who share a display name stay distinct to its self-approval check.
  function sdlc(args: string[], exitCode: 1 | 2 = 2): string {
    // Reads (status, ci) must work with no git identity, as on a CI runner; approvals check `who()` strictly.
    let me = "";
    try {
      me = who();
    } catch {
      // no identity configured: the engine gets an empty one and only a write would care
    }
    const env = {
      ...process.env,
      GIT_CONFIG_COUNT: "2",
      GIT_CONFIG_KEY_0: "user.name",
      GIT_CONFIG_VALUE_0: me,
      GIT_CONFIG_KEY_1: "user.email",
      GIT_CONFIG_VALUE_1: me,
    };
    try {
      return execFileSync(process.execPath, [bin, ...args], {
        cwd: root,
        env,
        encoding: "utf8",
        stdio: ["ignore", "pipe", "pipe"],
      }).trim();
    } catch (e) {
      const x = e as { stderr?: string; stdout?: string; message: string };
      throw new SeamError(
        (x.stderr || x.stdout || x.message).trim().split("\n").pop() ??
          "sdlc failed",
        exitCode,
      );
    }
  }

  const rows = (): Row[] =>
    sdlc(["status", "--json"])
      .split("\n")
      .filter(Boolean)
      .map((l) => JSON.parse(l) as Row);
  const find = (slug: string): Row | undefined =>
    rows().find((r) => r.slug === slug);
  const path = (row: Row, stage: GateStage) => `${row.change}/${FILE[stage]}`;

  function record(row: Row, stage: GateStage, i: number): GateRecord {
    const raw = row.statuses.split("/")[i] ?? "-";
    if (raw === "rejected")
      return { state: "rejected", approver: null, commit: null };
    if (raw !== "approved" && raw !== "accepted")
      return { state: "pending", approver: null, commit: null };
    const file = path(row, stage);
    const approver =
      /^approved_by:\s*(.+)$/m
        .exec(readFileSync(join(root, file), "utf8"))?.[1]
        ?.trim() ?? null;
    return {
      state: "approved",
      approver,
      commit: gitOr("log", "-1", "--format=%H", "--", file) || null,
    };
  }

  function toStatus(row: Row): ChangeStatus {
    const gates = Object.fromEntries(
      GATES.map((g, i) => [g, record(row, g, i)]),
    ) as Record<GateStage, GateRecord>;
    const stage: Stage =
      GATES.find((g) => gates[g].state !== "approved") ?? "build";
    return {
      schema: 1,
      change: row.slug,
      stage,
      artifactsDir: row.change,
      gates,
    };
  }

  function decide(
    slug: string,
    stage: GateStage,
    verb: "approve" | "reject",
  ): void {
    const row = find(slug);
    if (!row) throw new SeamError(`unknown change: ${slug}`, 2);
    const me = who();
    if (bots.has(me)) throw new SeamError("approver is a bot", 1);
    // the engine exempts intent from its self-approval rule; the seam does not
    if (verb === "approve") {
      const author = gitOr(
        "log",
        "-1",
        "--format=%ae",
        "--",
        path(row, stage),
      ).toLowerCase();
      if (!author)
        throw new SeamError(`${slug}/${stage}.md is not committed`, 1);
      if (author === me) throw new SeamError("self-approval is off", 1);
    }
    sdlc([verb, slug, stage], 1);
  }

  return {
    name: "morsadev",
    version: () =>
      (
        JSON.parse(readFileSync(join(PKG, "package.json"), "utf8")) as {
          version: string;
        }
      ).version,
    status(slug) {
      const row = find(slug);
      return row ? toStatus(row) : null;
    },
    next(): NextAction {
      const change = currentChange(root, (s) => find(s) !== undefined);
      if (!change) {
        return {
          schema: 1,
          change: null,
          stage: null,
          action: `no change for branch ${branchName(root)}: run sdlc-seam new <slug> --title <title>`,
        };
      }
      const st = toStatus(find(change) as Row);
      const msg =
        (JSON.parse(sdlc(["next", "--json"])) as { message?: string })
          .message ?? "";
      return {
        schema: 1,
        change,
        stage: st.stage,
        action:
          msg ||
          (st.stage === "build" ? "build, then ship" : `write ${st.stage}.md`),
      };
    },
    changesTouchedSince(base) {
      const dirs = gitOr("diff", "--name-only", `${base}...HEAD`, "--", CHANGES)
        .split("\n")
        .map((f) => f.split("/")[1])
        .filter(
          (d): d is string => !!d && !d.startsWith("_") && d !== "README.md",
        );
      const known = rows();
      return [
        ...new Set(
          dirs.map(
            (d) =>
              known.find((r) => r.change === `${CHANGES}/${d}`)?.slug ??
              d.replace(/^\d{4}-\d{2}-/, ""),
          ),
        ),
      ];
    },
    newChange(slug, title) {
      if (!SLUG.test(slug)) throw new SeamError(`invalid slug: ${slug}`, 2);
      if (title.trim() === "") throw new SeamError("title is required", 2);
      if (find(slug)) throw new SeamError(`change exists: ${slug}`, 2);
      sdlc(["new", slug, "--title", title, "--no-branch"]);
      const row = find(slug) as Row;
      // the engine writes only intent.md; the later gates need a file to carry their status
      for (const g of ["spec", "plan"] as const) {
        writeFileSync(
          join(root, path(row, g)),
          `---\nchange: ${slug}\nstatus: draft\nauthor: ${who()}\n---\n# ${title}: ${g}\n`,
        );
      }
      return row.change;
    },
    approve: (change, stage) => decide(change, stage, "approve"),
    reject: (change, stage) => decide(change, stage, "reject"),
  };
}
