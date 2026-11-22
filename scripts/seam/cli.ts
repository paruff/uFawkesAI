import { loadEngine, resolveConfigPath } from "./config.ts";
import { SeamError } from "./contract.ts";

const COMMANDS = ["next", "status", "gate", "new", "approve", "reject", "ci", "engine"];
const USAGE = `usage: sdlc-seam <${COMMANDS.join("|")}> [args]`;

function main(argv: string[]): void {
  const cmd = argv[0];
  if (!cmd || !COMMANDS.includes(cmd)) throw new SeamError(`${cmd ? `unknown subcommand: ${cmd}\n` : ""}${USAGE}`, 2);
  const engine = loadEngine(resolveConfigPath());
  if (cmd === "engine") {
    console.log(`${engine.name} ${engine.version()}`);
    return;
  }
  throw new SeamError(`${cmd}: not implemented`, 2); // shortcut: skeleton, #342/#343 implement the rest
}

try {
  main(process.argv.slice(2));
} catch (e) {
  console.error(e instanceof Error ? e.message : String(e));
  process.exit(e instanceof SeamError ? e.exitCode : 2);
}
