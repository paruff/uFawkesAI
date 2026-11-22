import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { currentChange, branchName } from "./branch.ts";
import { loadEngine, resolveConfigPath } from "./config.ts";
import { GATES, SeamError } from "./contract.ts";
import type { GateStage, SdlcEngine } from "./contract.ts";

const COMMANDS = ["next", "status", "gate", "new", "approve", "reject", "ci", "engine"];
const USAGE = `usage: sdlc-seam <${COMMANDS.join("|")}> [args]`;

function stageArg(s: string | undefined): GateStage {
  if (!GATES.includes(s as GateStage)) throw new SeamError(`stage must be one of ${GATES.join(", ")}`, 2);
  return s as GateStage;
}

/** Value of `--flag <v>`, undefined if absent; a missing or flag-like value is a usage error. */
function flag(args: string[], name: string): string | undefined {
  const i = args.indexOf(name);
  if (i < 0) return undefined;
  const v = args[i + 1];
  if (v === undefined || v.startsWith("--")) throw new SeamError(`${name} needs a value`, 2);
  return v;
}

function codePaths(root: string): string[] {
  const file = join(root, ".artifact-chain-paths");
  if (!existsSync(file)) return ["src/"];
  const paths = readFileSync(file, "utf8").split("\n").map((l) => l.trim()).filter((l) => l !== "" && !l.startsWith("#"));
  if (paths.length === 0) throw new SeamError(".artifact-chain-paths lists no paths", 2);
  return paths;
}

// Verdicts are computed here from `status`, so no adapter can drift on them.
function gate(engine: SdlcEngine, root: string, args: string[]): void {
  const [a, b] = args;
  const stage = stageArg(b ?? a);
  const change = b === undefined ? currentChange(root, (s) => engine.status(s) !== null) : a;
  if (!change) throw new SeamError(`no change for branch ${branchName(root)}`, 2);
  const st = engine.status(change);
  if (!st) throw new SeamError(`unknown change: ${change}`, 2);
  const g = st.gates[stage];
  if (g.state !== "approved") throw new SeamError(`${change}/${stage} is ${g.state}`, 1);
}

function ci(engine: SdlcEngine, root: string, base: string): void {
  let code: string[];
  let touched: string[];
  try {
    code = execFileSync("git", ["diff", "--name-only", `${base}...HEAD`, "--", ...codePaths(root)], { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).split("\n").filter(Boolean);
    touched = engine.changesTouchedSince(base);
  } catch (e) {
    if (e instanceof SeamError) throw e;
    throw new SeamError(`cannot diff against ${base} (shallow clone? fetch it): ${(e as Error).message.split("\n")[0]}`, 2);
  }
  const problems: string[] = [];
  if (code.length > 0 && touched.length === 0) {
    problems.push(`code paths changed with no change (create one with sdlc-seam new):\n  ${code.join("\n  ")}`);
  }
  for (const change of touched) {
    const st = engine.status(change);
    if (!st) problems.push(`${change}: unknown change`);
    else for (const g of GATES) if (st.gates[g].state !== "approved") problems.push(`${change}/${g} is ${st.gates[g].state}`);
  }
  if (problems.length > 0) throw new SeamError(`ci failed:\n${problems.join("\n")}`, 1);
  console.log("ci: ok");
}

function main(argv: string[]): void {
  const [cmd, ...args] = argv;
  if (!cmd || !COMMANDS.includes(cmd)) throw new SeamError(`${cmd ? `unknown subcommand: ${cmd}\n` : ""}${USAGE}`, 2);
  const cfgPath = resolveConfigPath();
  const engine = loadEngine(cfgPath);
  const root = dirname(cfgPath);
  const json = args.includes("--json");
  switch (cmd) {
    case "engine":
      console.log(`${engine.name} ${engine.version()}`);
      return;
    case "next": {
      const n = engine.next();
      console.log(json ? JSON.stringify(n) : n.action);
      return;
    }
    case "status": {
      const change = args.find((a) => !a.startsWith("--"));
      if (!change) throw new SeamError("usage: status <change> --json", 2);
      const st = engine.status(change);
      if (!st) throw new SeamError(`unknown change: ${change}`, 2);
      console.log(json ? JSON.stringify(st) : `${st.change}: ${st.stage}`);
      return;
    }
    case "gate":
      gate(engine, root, args);
      return;
    case "new": {
      const slug = args[0];
      const title = flag(args, "--title");
      if (!slug || slug.startsWith("--") || !title) throw new SeamError("usage: new <slug> --title <title>", 2);
      console.log(engine.newChange(slug, title));
      return;
    }
    case "approve":
    case "reject": {
      if (!args[0] || !args[1]) throw new SeamError(`usage: ${cmd} <change> <stage>`, 2);
      engine[cmd](args[0], stageArg(args[1]));
      return;
    }
    case "ci":
      ci(engine, root, flag(args, "--base") ?? "origin/main");
      return;
  }
}

try {
  main(process.argv.slice(2));
} catch (e) {
  console.error(e instanceof Error ? e.message : String(e));
  process.exit(e instanceof SeamError ? e.exitCode : 2);
}
