# ADR-0004: Audio pipeline — STT→LLM→TTS first, realtime API as a later swap

- **Status:** proposed
- **Date:** 2026-07-26
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

The device must hold a Japanese voice conversation (REQ-002) with a response
latency target of P50 ≤ 3.0 s / P95 ≤ 6.0 s from end of utterance to start
of response audio (REQ-003, provisional, re-measured in E4). All model calls
go through Azure AI Foundry deployments, swappable without firmware change
(REQ-004), keylessly via Managed Identity (REQ-006).

The raw plan already commits to the shape: the E2 epic body specifies an
STT→LLM→TTS pipeline calling Foundry keylessly, built as a pipeline
abstraction into which a realtime mode can later be inserted
("後日Realtimeモードを差し込める構造"), with realtime-mode implementation
explicitly out of E2 scope; the E1 body allocates three logical deployment
names — `stackchan-chat`, `stackchan-stt`, `stackchan-tts`; the E4 body
names streaming and ahead-of-time TTS as the latency levers if targets are
missed. Sources:
`docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`,
`docs/context/plan-intake/stackchan-plan/epics/E1-azure-foundation.md`,
`docs/context/plan-intake/stackchan-plan/epics/E4-e2e-conversation.md`,
`docs/context/azure-foundry/seed-from-plan-intake.md`.

The tension: a speech-to-speech realtime API could cut latency, but it is a
bigger integration bet; the staged pipeline is simpler, observable per
stage, and lets each stage's model be swapped independently.

## Decision

The relay proxy implements the conversation as a staged pipeline —
STT → LLM → TTS — of three Foundry calls addressed by the logical
deployment names `stackchan-stt`, `stackchan-chat`, `stackchan-tts`, behind
a single pipeline abstraction. A realtime (speech-to-speech) mode is a
later, optional swap of that abstraction's implementation inside the proxy
only: the device–proxy protocol (ADR-0003) and the firmware are unaffected
by the swap. Model and persona changes are proxy configuration changes,
hot-reloadable without restart (REQ-004, E2 body). This ADR records the
swap point; designing the realtime mode is explicitly not decided here.

## Consequences

- Easier: each stage is independently swappable and measurable (per-stage
  latency breakdown to Application Insights is an E2 success criterion,
  feeding the REQ-003 report); Japanese quality problems can be isolated to
  a stage.
- Harder: three sequential network calls put a floor under latency; if E4
  measurements miss REQ-003, the ordered levers are streaming between
  stages and ahead-of-time TTS (E4 body), then a realtime-mode
  implementation through the recorded swap point, then a REQ-003 revision
  PR — in that order.
- The pipeline abstraction is a hard E2 design constraint: nothing
  stage-specific may leak into the device protocol or the session layer,
  or the swap point is lost.
- Open points to confirm in E1 (the concrete Azure/Foundry design notes are
  not yet exported — see `docs/context/azure-foundry/INDEX.md`): which
  actual models back the three logical deployment names, and their
  Japanese STT/TTS quality; Foundry API surface used for each stage.
- Open points to confirm in E2: streaming granularity between stages;
  persona injection point in the LLM stage; hot-reload mechanism.
- Open point to confirm in E4: whether REQ-003 holds on the staged
  pipeline at all — this ADR is revisited if the levers above are
  exhausted.

## References

- `docs/agreements/requirements.md` — REQ-002, REQ-003, REQ-004, REQ-006
- `docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md` —
  pipeline, hot reload, realtime slot (raw numbering: the epic's
  "ADR-0003（パイプライン）"; renumbered per ADR-0001)
- `docs/context/plan-intake/stackchan-plan/epics/E1-azure-foundation.md` —
  logical deployment names
- `docs/context/plan-intake/stackchan-plan/epics/E4-e2e-conversation.md` —
  latency levers (streaming, ahead-of-time TTS)
- `docs/context/azure-foundry/seed-from-plan-intake.md`,
  `docs/context/azure-foundry/INDEX.md`
- ADR-0002 (overall architecture), ADR-0003 (device–proxy protocol)
