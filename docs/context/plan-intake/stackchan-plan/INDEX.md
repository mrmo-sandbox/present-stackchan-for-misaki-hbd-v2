---
source: docs/context/plan-intake/stackchan-plan/ (bundle contents listed below)
retrieved: 2026-07-25
method: ai-summary
collector: Claude Code session claude-child-t-e0-6 (T-E0-6, issue #12)
sensitivity: internal
status: raw
---

# INDEX — plan-intake/stackchan-plan (bundle v1)

StackChan plan bundle v1, produced in the Claude planning conversation and
committed 2026-07-18 (commit 35c1f6f, per CODE-KICKOFF.md Step 5). Retrofit
note: this INDEX and the provenance headers on CODE-KICKOFF.md and HANDOFF.md
were added retroactively by T-E0-6 (2026-07-25); no original bundle content
was altered. Content is Japanese per decision Q2 (Epic #2 decision record).

## Conflicts / open questions

- `epics/*.md` are obsolete as working documents since the Epics were filed as
  issues #2-#10 on 2026-07-18 (HANDOFF.md declares the issues canonical
  post-filing). They are retained here as raw provenance only — edit the
  issues, never these files.
- NG-007 in `agreements-draft/non-goals.md` embeds an unresolved item (iOS
  distribution method); per decision Q7 it becomes its own issue at
  distillation, before E5.
- The division-of-labor wording in HANDOFF.md/epics (Codex-parallel
  implementation, exec label readings) is superseded by the Epic #2 decision
  record (2026-07-25) where they disagree; see
  `docs/context/design-sessions/2026-07-claude-planning/decision-record-2026-07-25.md`.
- Bundle files other than CODE-KICKOFF.md and HANDOFF.md carry no provenance
  header: T-E0-6's brief mandated headers on those two files only and forbade
  touching the rest; their provenance is recorded here instead (same source
  and dates as the two headed files).

## Files

- `CODE-KICKOFF.md` — execution runbook used to apply the tt1 scaffold, file
  Epics #2-#10, and store this bundle (Steps 0-10); provenance input for this
  retrofit.
- `HANDOFF.md` — bundle map: contents, Epic schedule table (E0-E8 dates and
  blocked-by graph), execution order, and the "E0 に着手" pointers naming the
  research material to land under docs/context/.
- `agreements-draft/requirements.md` — REQ-001..019 first-draft table; input
  to the E0 distillation PR (T-E0-7); Source column cites the four
  docs/context topic directories.
- `agreements-draft/non-goals.md` — NG-001..008 first draft; same role.
- `epics/E0-scaffold-and-distill.md` — E0 epic body as filed (scaffold tuning
  + knowledge distillation); superseded by issue #2.
- `epics/E1-azure-foundation.md` — E1 epic body (Azure IaC foundation);
  superseded by issue #3.
- `epics/E2-proxy-mvp.md` — E2 epic body (relay proxy MVP, protocol v0);
  superseded by issue #4.
- `epics/E3-firmware-mvp.md` — E3 epic body (custom firmware MVP); superseded
  by issue #5.
- `epics/E4-e2e-conversation.md` — E4 epic body (E2E conversation milestone);
  superseded by issue #6.
- `epics/E5-mgmt-api-ios-alpha.md` — E5 epic body (management API + iOS
  alpha); superseded by issue #7.
- `epics/E6-line-miniapp-alpha.md` — E6 epic body (LINE mini-app alpha);
  superseded by issue #8.
- `epics/E7-notify-ops.md` — E7 epic body (notifications and operations);
  superseded by issue #9.
- `epics/E8-present-finish.md` — E8 epic body (present finishing, rehearsal
  buffer); superseded by issue #10.
- `scripts/create-epics.sh` — one-shot Epic filing script (NOT idempotent;
  re-running duplicates issues). Already executed 2026-07-18; keep for
  provenance, do not re-run.
