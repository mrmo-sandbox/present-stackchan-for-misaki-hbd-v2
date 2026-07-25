---
name: task-routing
description: Decide where and with what each Task issue should run — execution surface (exec:cli / exec:app / exec:ide label; exec:cloud is reserved and unused in this project), suggested agent role, and suggested model/reasoning effort. Use this while decomposing an Epic, when filling the Routing block of ai-task issues, when a task changes nature mid-flight and needs re-routing, and whenever someone asks which surface (Claude Code session, Codex desktop app, human-in-the-loop hardware work) should handle a piece of work.
---

# Task Routing

Every Task issue carries exactly one `exec:*` label plus a filled Routing
block. Routing is decided at planning time so that dispatch is mechanical:
orchestrators and humans read the label and act, instead of re-debating tool
choice per task.

## Routing inputs

Score the task on five axes before choosing:

1. **Ambiguity** — is the brief fully specified, or will it need human
   judgment calls mid-task?
2. **Local dependency** — does it need physical hardware (flash, serial, HIL),
   local credentials, or a specific machine?
3. **Parallelism value** — is it one of many independent tasks worth running
   concurrently?
4. **Sensitivity** — does it expose data that must not leave the machine?
5. **Reasoning depth** — mechanical transformation, or design-grade thinking?

## Surface matrix

| Label | Surface | Strengths | Choose when |
|---|---|---|---|
| `exec:cli` | Claude Code session | Scriptable, composable with `gh`, repo-wide edits from a local checkout, plan-graph manipulation | Planning, docs, and scripted repo work; the planner/orchestrator surface during Epic E0 |
| `exec:app` | Codex desktop app session | Steerable in real time, per-session model choice, parallel local work isolated by worktrees | Implementation work with a complete brief; from Epic E1 on, also planning and orchestration |
| `exec:ide` | Human in the loop (editor/terminal on the connected machine) | Human judgment on tap, full local toolchain, hardware access (e.g., PlatformIO upload/monitor) | Ambiguous or exploratory work; design spikes; anything touching physical devices (flash, serial, HIL) |
| `exec:cloud` | Reserved — unused in this project | — | Never; the slug exists only so the label set and historical issues stay stable |

## Hard rules

- **Hardware rule.** Building firmware and running `native`-env tests can go
  anywhere; flashing, serial monitoring, and hardware-in-the-loop verification
  route to `exec:ide` (or an `exec:app` session on the machine physically
  connected to the device). Never let a task on a surface without device
  access carry a hardware-verified acceptance criterion.
- **Sensitivity rule.** Tasks handling data that must stay local route to
  `exec:app`/`exec:ide` with a local model suggested in the Routing block.
- **Ambiguity rule.** If you cannot write objectively checkable acceptance
  criteria, the task is not ready for an autonomous `exec:cli`/`exec:app`
  session — either sharpen the brief or route to `exec:ide`.

## Model / reasoning suggestion

The Routing block's model suggestion is advisory (pickers and availability
change), but the effort tier is meaningful:

| Tier | Use for | Examples of intent |
|---|---|---|
| `high-reasoning` | Planning, architecture, replanning, review, tricky debugging | frontier-class model, extended/high reasoning effort |
| `standard` | Ordinary implementation with good briefs | default model settings |
| `fast` | Mechanical edits, renames, formatting, boilerplate | smaller/faster model |
| `local` | Sensitive data, offline work | on-device model |

## Role suggestion

Suggest a role when a specialized definition exists in `.github/agents/`
(e.g., `planner`, `orchestrator`, `reviewer`) or in the client's agent picker
(e.g., security- or docs-focused agents). Leave as `default` otherwise; do not
invent role names that no surface provides. The planner/orchestrator role runs
as a Claude Code session during Epic E0 and in the Codex desktop app from E1
on (E0 decision record).

## Re-routing

A task changes surface when its nature changes: an `exec:app` task that turns
ambiguous or hits hardware comes back as `exec:ide`; an exploratory task whose
outcome is now a crisp spec goes out again as `exec:cli` or `exec:app`.
Re-routing is a plan change: swap the `exec:*` label, adjust the Routing
block, note one line of rationale on the issue.
