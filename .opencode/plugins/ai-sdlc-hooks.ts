import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import path from "node:path";

const PROTECTED_PATHS_CONFIG = JSON.parse(
  readFileSync(path.join(process.cwd(), "scripts/hooks/protected-paths.json"), "utf-8")
) as { protectedBasenamePatterns: string[]; protectedPathSegments?: string[] };
const PROTECTED_BASENAME = PROTECTED_PATHS_CONFIG.protectedBasenamePatterns.map((s) => new RegExp(s));
const PROTECTED_SEGMENTS = PROTECTED_PATHS_CONFIG.protectedPathSegments ?? [".git"];
const FORMATTERS: Array<{ ext: string; cmd: string[] }> = [
  { ext: ".ts", cmd: ["npx", "-y", "prettier", "--write"] },
  { ext: ".js", cmd: ["npx", "-y", "prettier", "--write"] },
  { ext: ".py", cmd: ["black"] },
  { ext: ".go", cmd: ["gofmt", "-w"] },
  { ext: ".rs", cmd: ["rustfmt"] }
];

function isProtected(targetPath: string): boolean {
  const normalized = path.normalize(targetPath).replace(/\\/g, "/");
  const segments = normalized.split("/").filter(Boolean);
  const basename = segments[segments.length - 1] ?? "";
  if (PROTECTED_SEGMENTS.some((seg) => segments.includes(seg))) return true;
  return PROTECTED_BASENAME.some((re) => re.test(basename));
}

export default {
  hooks: {
    PreToolUse: [
      {
        matcher: "Edit|Write",
        run: ({ filePath }: { filePath?: string }) => {
          if (!filePath) return { exitCode: 0 };
          if (isProtected(filePath)) {
            return {
              exitCode: 2,
              message: `Blocked edit to protected path: ${filePath}`
            };
          }
          return { exitCode: 0 };
        }
      }
    ],
    PostToolUse: [
      {
        matcher: "Edit|Write",
        run: ({ filePath }: { filePath?: string }) => {
          if (!filePath) return { exitCode: 0 };
          const ext = path.extname(filePath);
          const formatter = FORMATTERS.find((f) => f.ext === ext);
          if (!formatter) return { exitCode: 0 };
          try {
            execFileSync(formatter.cmd[0], [...formatter.cmd.slice(1), filePath], { stdio: "inherit" });
            return { exitCode: 0 };
          } catch (error) {
            return { exitCode: 1, message: `Formatter failed for ${filePath}: ${String(error)}` };
          }
        }
      }
    ],
    SessionStart: [
      {
        matcher: "compact",
        run: () => ({
          exitCode: 0,
          message:
            "Use the project's package manager. Run /verify before claiming completion. Never edit protected files."
        })
      }
    ]
  }
};
