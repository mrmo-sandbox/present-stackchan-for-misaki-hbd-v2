# Copilot Repository Instructions

Trust these instructions. Search the codebase only when something here is
missing or demonstrably wrong — and when that happens, propose a fix to this
file as part of your PR (see the retro skill).

`AGENTS.md` at the repository root defines the operating protocol
(persistence rule, record-before-report, verify-before-done, unit of work,
single-writer rule, Ambiguity rule). It applies to you in full. This file adds the operational
details Copilot needs to work efficiently in this repository.

## Repository layout

- `docs/context/` — raw collected material: plan-intake bundle (epics,
  agreement drafts), topic seeds (`stackchan-hw/`, `azure-foundry/`,
  `line-miniapp/`), design-session records. Japanese allowed (AGENTS.md §8).
- `docs/agreements/` — reviewed requirements, ADRs, glossary, non-goals,
  retro log. English only; change via PR (`docs.instructions.md`).
- `scripts/` — repo automation: `tuning-status.sh` (onboarding regression
  guard), `check-md-links.sh`, `check-template-sync.sh`, `retro-hygiene.sh`,
  `setup-labels.sh`, `setup-project.sh`, `setup-ruleset.sh` (POST-only
  bootstrap — never rerun on an existing ruleset).
- `.github/workflows/` — `ci.yml` (jobs `quality` and `scaffold-self-check`,
  both required by the branch ruleset), `copilot-setup-steps.yml`,
  `retro-hygiene.yml`.
- `.github/skills/` — procedures. `.github/instructions/` — path-scoped rules.
- `.github/agents/` — role definitions (orchestrator, planner, reviewer).
- `.agents/skills/` — Codex discovery links to the canonical procedures.
- No application code yet: `firmware/`, proxy/server, and app trees arrive
  with Epics E1+ (`firmware.instructions.md` is provisional until E3).

## Environment setup and validated commands

The repository is docs/planning-only (E0): nothing to build. Every command
below was executed during onboarding (#17) on a clean checkout; each runs in
under one second. Prerequisites: bash 3.2+, git, `gh` (authenticated — check
`gh auth status`), jq, shellcheck v0.11.0 and actionlint 1.7.12 (the ci.yml
pins). No failures or workarounds were observed.

Run steps in this order. Do not improvise alternative commands when these work.

1. `bash scripts/tuning-status.sh` — expect `TUNED: ...`, exit 0. A
   `CUSTOMIZE` marker reappearing fails this and the CI `quality` job.
2. `bash scripts/check-md-links.sh` — Markdown path references resolve.
3. `bash scripts/check-template-sync.sh` — issue forms match body templates.
4. `git ls-files -z '*.sh' ':!docs/context/**' | xargs -0 shellcheck -S style`
   — shell hygiene. `docs/context/**` is raw intake material and is excluded
   here and in step 2's script for the same reason: it must never require
   edits to keep checks green.
5. `actionlint -color` — workflow lint.

When the first real toolchain lands (E1+), extend this list together with
`.github/workflows/ci.yml` and `.github/workflows/copilot-setup-steps.yml`
(the Sync Triangle — see the project-onboarding skill).

## Working a Task issue

The Task issue body is your work order. It follows
`.github/ISSUE_TEMPLATE/ai-task.yml` and contains: Objective, Context &
references, Acceptance criteria, Out of scope, File ownership, Verification,
and Routing. Read all of it before writing code.

1. Comment on the issue that you are starting (one line is enough).
2. Work on branch `task/<issue-number>-<short-slug>`. Touch only paths listed
   under **File ownership**.
3. Keep the PR description synchronized with reality: map each acceptance
   criterion to evidence using the table in the PR template.
4. Run every command in the issue's **Verification** section before marking the
   PR ready. If a command fails, fix the cause or report the blocker — never
   delete or weaken the check.
5. If the task turns out to be materially different from its description,
   follow the Ambiguity rule in `AGENTS.md` (comment, label `needs:human` or
   `needs:replan`, stop).
6. Finish with the record-before-report comment on the issue: status, evidence,
   deviations, follow-ups (format in
   `.github/skills/session-orchestration/SKILL.md`).

Two automated-writer lanes sit outside this flow: dependabot PRs are exempt
from issue-first; the human merges them directly. Monthly retro-hygiene
issues are `needs:human` by construction; the human triages them.

## Pull request conventions

- Title: imperative mood, mirrors the Task issue title.
- Body: fill `.github/PULL_REQUEST_TEMPLATE.md` completely, including
  `Closes #<n>` and the evidence table.
- Keep PRs reviewable: one Task issue per PR; if the diff exceeds roughly 400
  changed lines outside generated code, propose splitting via `needs:replan`
  instead of pushing on.

## Things that will get your PR rejected

- Diff touches paths outside the issue's File ownership section.
- Acceptance criteria without evidence, or verification commands not run.
- Secrets, tokens, or credentials in code or config.
- Modified CI workflows, rulesets, or checks without an explicit mandate.
- Language policy (AGENTS.md §8) violated: agreements, code comments, commit
  messages, PR bodies, and `.github/` files must be English (Japanese is
  allowed only in `docs/context/` raw material, issue titles/bodies, and the
  root `README.md`).
