#!/usr/bin/env bash
# setup-labels.sh — create/refresh the canonical label set this scaffold
# relies on (plan-management, task-routing, session-orchestration skills).
# Idempotent: uses `gh label create --force`.
#
# Usage: setup-labels.sh [-R owner/repo]

set -euo pipefail

REPO_ARGS=()
[[ "${1:-}" == "-R" && -n "${2:-}" ]] && REPO_ARGS=(--repo "$2")
command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not found" >&2; exit 1; }

# ${arr[@]+"${arr[@]}"} guards the empty-array expansion, which is an unbound
# variable under `set -u` on bash 3.2 (macOS /bin/bash); fixed in bash 4.4.
create() { gh label create "$1" ${REPO_ARGS[@]+"${REPO_ARGS[@]}"} --color "$2" --description "$3" --force; }

create "type:epic"    "5319E7" "Outline item; parent of Task sub-issues (plan-management)"
create "type:task"    "0E8A16" "Self-contained work order for one agent session"
create "ai:ready"     "1D76DB" "Brief meets the planner quality bar; dispatchable when unblocked"
create "needs:human"  "B60205" "Escalation: judgment/trust decision required (AGENTS.md, Ambiguity rule)"
create "needs:replan" "D93F0B" "Escalation: plan/scope must change before work continues"
create "exec:cloud"   "C2E0C6" "Route: reserved — unused in this project"
create "exec:app"     "BFDADC" "Route: Codex desktop app session — implementation; planning from E1 on"
create "exec:cli"     "FEF2C0" "Route: Claude Code session — planning, docs, scripted repo work"
create "exec:ide"     "F9D0C4" "Route: human in the loop — hardware work (flash, serial, HIL)"
create "retro:candidate" "EDEDED" "Observed scaffold friction; promote to a retro: PR at the 2nd occurrence"

echo "Done. 10 labels ensured."
