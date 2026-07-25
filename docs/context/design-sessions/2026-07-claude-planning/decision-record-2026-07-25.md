---
source: https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/2#issuecomment-5077974019
retrieved: 2026-07-25
method: export
collector: Claude Code session claude-child-t-e0-6 (T-E0-6, issue #12)
sensitivity: internal
status: raw
---

<!-- Verbatim export of the plan decision-record comment posted on Epic #2. Original body below this line, unedited. -->

## Plan decision record — scaffold audit outcomes & E0 decomposition (2026-07-25)

A full scaffold audit (16 findings, 5 adversarial review rounds) was run in the planning session to verify this repo supports the intended operating model. The full audit text will be committed with a provenance header under `docs/context/` by the context-intake task (T-E0-6 below); this comment records the decisions and the resulting E0 decomposition so no decision lives only in a chat session.

### Division of labor (revised, supersedes the wording in this Epic's body)

- **E0 (initial planning + scaffold tuning):** Claude (Claude Code) hosts the planner/orchestrator role.
- **E1 onward:** the Codex desktop app hosts BOTH implementation and planning/orchestration (epic breakdown, task creation, rolling-wave replanning). Claude may be re-seated for major replans at the human's discretion — the planning host is a seat, not a lock-in.
- **Human:** judgment calls (`needs:human`), PR merges (the merge button is human-only), hardware work.
- The last E0 planning task (E1 breakdown) runs **on Codex as a supervised handover rehearsal** while the Claude planning session is still available.

### Decisions (Q1–Q7 from the audit)

1. **copilot-setup-steps.yml:** keep and fill (one real setup step); avoids the five-file deletion ripple and keeps a future Copilot-cloud option open.
2. **Language policy:** amend AGENTS.md §8 AND `.github/instructions/docs.instructions.md` via retro PR — Japanese becomes allowed for `docs/context/` raw material, issue titles/bodies, and the root README; agreements (REQ/NG/ADR/glossary), code comments, commit messages, and PR bodies stay English.
3. **Ruleset:** PATCH ruleset 19131818 to `required_approving_review_count=0` + enforcement=active (after the `quality` job becomes real); "human presses merge" = the approval gate; reword the six human-approval statements accordingly; agents never merge.
4. **Automated writers:** dependabot PRs are exempt from issue-first (human merges directly); monthly retro-hygiene issues are triaged by the human.
5. **exec:\* labels:** reinterpret slugs, no renames. `exec:cli` = Claude Code session (planning/docs/scripted repo work — E0 phase); `exec:app` = Codex desktop session (implementation; also planning from E1); `exec:ide` = human-in-the-loop / hardware; `exec:cloud` = reserved, unused.
6. **Claude surface:** Claude Code only — no Claude Desktop lane (audit F16 becomes moot). Scoped to E0 per the division of labor above. ADR-0001 records this.
7. **NG-007 distribution method:** extracted into its own tracked issue at distillation time (decide before E5); NG-007 itself is accepted with the settled part only.

### E0 decomposition (created as sub-issues of this Epic, blocked-by wired, dates on board #5)

`T-E0-0` hygiene batch (CI unbreak + agent-tool wiring) → unblocks `T-E0-1` (exec:* reinterpretation), `T-E0-5` (constitution amendments), `T-E0-6` (context intake); then `T-E0-1b` (ADR-0001), `T-E0-2` (cross-tool dispatch doc), `T-E0-3` (project-onboarding + ruleset enablement), `T-E0-7` (agreements distillation), `T-E0-8` (ADR-0002..0006 + protocol v0 spec), `T-E0-9` (E1 breakdown — handover rehearsal on Codex, `exec:app`).

**Rationale:** audit findings F1–F16 (full text lands via T-E0-6). Note the ADR renumbering: the raw epics payload pre-allocated ADR-0001..0005 to architecture topics; ADR-0001 is now the division-of-labor record and the architecture ADRs shift to ADR-0002..0006 (sequential numbering per docs.instructions.md).

