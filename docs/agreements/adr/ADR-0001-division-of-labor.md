# ADR-0001: Division of labor and dispatch seams

- **Status:** accepted
- **Date:** 2026-07-25
- **Supersedes:** none

## Context

The repository runs the tt1 scaffold, whose defaults assume GitHub
Copilot surfaces. The actual agent lineup differs: Claude Code hosts
planning during Epic E0, the Codex desktop app hosts implementation now
and planning from E1 on, and the human merges every PR. The scaffold's
`exec:*` labels (`.github/skills/task-routing/SKILL.md`), its approval
flow, and its planner/orchestrator seat therefore needed a mapping onto
that lineup. A scaffold audit (16 findings) on Epic #2 produced a Q1–Q7
decision record; Q3, Q5, and Q6 — plus the branch-naming and board
conventions they touch — are frozen here as the first accepted ADR.

## Decision

1. **`exec:*` reinterpretation (Q5).** Slugs are reinterpreted, not
   renamed:

   | Label | Surface |
   |---|---|
   | `exec:cli` | Claude Code session (planning, docs, scripted repo work) |
   | `exec:app` | Codex desktop app session (implementation) |
   | `exec:ide` | Human-in-the-loop / hardware work |
   | `exec:cloud` | Reserved, unused for now |

2. **Planning seat (Q6).** The Claude surface is Claude Code only. The
   planner/orchestrator seat is held by Claude Code during E0 and by the
   Codex desktop app from E1 on; the planning host is a seat, not a
   lock-in: the human may re-seat any capable agent (e.g. Claude) for
   major replans.
3. **Handover mechanism.** The E1 breakdown task (T-E0-9) runs on Codex
   as a supervised rehearsal of the seat handover.
4. **§4 branch-name widening.** Tool-generated number-less branch names
   are acceptable when the PR body carries `Closes #<n>`. As amended in
   `AGENTS.md` §4 (now on main): "a tool-generated name (e.g.
   `<user>-task-<n>-<slug>`, or one without the issue number) is an
   accepted equivalent when the PR body links the issue with
   `Closes #<n>` — no deviation note needed."
5. **Board #5 Status convention.** Items move Todo → In Progress when a
   session starts on the task, and Done when the issue closes.
6. **Human-merge rule (Q3).** The merge button is human-only; agents
   never merge. The ruleset runs with
   `required_approving_review_count=0`; the human's merge is the
   approval.

## Consequences

- Dispatch is mechanical: routing reads the reinterpreted `exec:*` label
  and the Routing block; no per-task tool debate.
- ADR renumbering: the raw epics payload
  (`docs/context/plan-intake/stackchan-plan/epics/E0-scaffold-and-distill.md`,
  line 11) pre-allocated ADR-0001..0005 to five architecture topics
  (overall architecture; device⇄proxy protocol v0; audio pipeline —
  STT→LLM→TTS first, Realtime later; auth — LINE ID + allowlist; client
  strategy — iOS-first, mini-app subset). Those shift to ADR-0002..0006;
  the architecture-ADR drafting tasks pick their numbers from this note.
- Constitution and skill texts reflecting these decisions are owned by
  the constitution-amendments task, not this ADR; this record is the
  decision, not the propagation.
- Re-seating the planning host is a human decision recorded on the Epic,
  never an agent's own call.

## References

- Epic #2 (approval trail, with the human's chat GO):
  https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/2
- Decision record comment (Q1–Q7):
  https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/2#issuecomment-5077974019
- `docs/context/plan-intake/stackchan-plan/epics/E0-scaffold-and-distill.md`
  — raw payload with the pre-allocated ADR numbering (line 11)
- `.github/skills/task-routing/SKILL.md` — original surface matrix
- `.github/instructions/docs.instructions.md` — agreements change
  control and ADR numbering rules
- `docs/agreements/adr/ADR-0000-template.md` — format
