export type Stage = "intent" | "spec" | "plan" | "build" | "ship" | "incident";
export type GateStage = "intent" | "spec" | "plan";
export const GATES: GateStage[] = ["intent", "spec", "plan"];
export type GateState = "approved" | "rejected" | "pending";
export interface GateRecord { state: GateState; approver: string | null; commit: string | null }
export interface ChangeStatus {
  schema: 1; change: string; stage: Stage; artifactsDir: string;
  gates: Record<GateStage, GateRecord>;
}
export interface NextAction { schema: 1; change: string | null; stage: Stage | null; action: string }
export interface SdlcEngine {
  readonly name: string;
  version(): string;
  next(): NextAction;
  status(change: string): ChangeStatus | null;      // null = unknown change
  changesTouchedSince(base: string): string[];       // change slugs in the diff
  newChange(slug: string, title: string): string;     // returns artifactsDir
  approve(change: string, stage: GateStage): void;    // throws SeamError on refusal
  reject(change: string, stage: GateStage): void;
}
export class SeamError extends Error {
  readonly exitCode: 1 | 2;
  constructor(message: string, exitCode: 1 | 2) { super(message); this.exitCode = exitCode; }
}
