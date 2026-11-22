import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { SeamError } from "./contract.ts";
import type { SdlcEngine } from "./contract.ts";
import { createFakeEngine } from "./adapters/fake.ts";

// Adapters register here; each gets the parsed config and the repo root.
type Config = { botIdentities?: string[] };
const ADAPTERS: Record<string, (cfg: Config, root: string) => SdlcEngine> = { fake: createFakeEngine };

export function resolveConfigPath(): string {
  if (process.env.SEAM_CONFIG) return process.env.SEAM_CONFIG;
  const top = execFileSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" }).trim();
  return join(top, ".sdlc-engine.json");
}

export function loadEngine(cfgPath: string): SdlcEngine {
  if (!existsSync(cfgPath)) throw new SeamError("no .sdlc-engine.json", 2);
  let cfg: Config & { engine?: unknown };
  try {
    cfg = JSON.parse(readFileSync(cfgPath, "utf8")) as Config & { engine?: unknown };
  } catch (e) {
    throw new SeamError(`invalid .sdlc-engine.json: ${(e as Error).message}`, 2);
  }
  const name = process.env.SEAM_ADAPTER ?? cfg.engine;
  if (typeof name !== "string" || name === "") {
    throw new SeamError('invalid .sdlc-engine.json: missing "engine"', 2);
  }
  const make = Object.hasOwn(ADAPTERS, name) ? ADAPTERS[name] : undefined;
  if (!make) throw new SeamError(`unknown engine: ${name}`, 2);
  return make(cfg, dirname(cfgPath));
}
