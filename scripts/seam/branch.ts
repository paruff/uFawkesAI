import { execFileSync } from "node:child_process";

// shortcut: branch `change/<slug>` or `<type>/<slug>` maps to the slug, no other naming scheme.
export function branchName(root: string): string {
  return execFileSync("git", ["rev-parse", "--abbrev-ref", "HEAD"], { cwd: root, encoding: "utf8" }).trim();
}

/** The change the current branch maps to, or null. `known` says whether the engine has that slug. */
export function currentChange(root: string, known: (slug: string) => boolean): string | null {
  const branch = branchName(root);
  const slug = branch.startsWith("change/") ? branch.slice("change/".length) : (branch.split("/").pop() ?? "");
  return slug !== "" && known(slug) ? slug : null;
}
