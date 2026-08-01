# ADR-0004: Realtime-first conversation with one governed intelligence path

- **Status:** proposed
- **Date:** 2026-07-26
- **Revised:** 2026-08-01
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

The device must hold a Japanese voice conversation (REQ-002) with a response
latency target of P50 <= 3.0 s / P95 <= 6.0 s from end of utterance to start
of response audio (REQ-003, provisional, re-measured in E4). All model calls
go through Azure AI Foundry deployments, swappable without firmware change
(REQ-004), keylessly via Managed Identity (REQ-006). Device credentials and
the provider-neutral device wire contract remain fixed by REQ-005, REQ-008,
ADR-0002, ADR-0003, and Protocol v0.

This ADR originally proposed a staged STT -> LLM -> TTS pipeline. While the
ADR was still `proposed`, the human selected a Realtime-first architecture as
the authoritative product direction in the
[Issue #31 decision](https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/31#issuecomment-5150875484).
This revision records that new proposal without erasing the earlier proposal
or its rationale; the historical proposal appears below.

Current Microsoft documentation establishes the available architectural
primitives, not a permanent model or lifecycle selection: Realtime supports a
session-oriented speech-to-speech WebSocket interaction; Microsoft Agent
Framework (MAF) supports a single agent, model clients, sessions, and function
middleware; and Agent Governance Toolkit (AGT) can evaluate actions in-process
but requires explicit policy initialization. Exact Azure model identifiers,
versions, deployment types, capacity, endpoints, preview/lifecycle posture,
quota, prices, and any approved fallback remain the time-sensitive decision in
Issue #31 and ADR-0007.

## Decision

### Realtime-first direct path

Use the simplest initial direct path for routine conversation:

`device WSS -> relay proxy/audio adapter -> Azure Foundry Realtime
mini-class deployment -> relay proxy -> device`.

1. The device sends and receives Protocol v0 audio over its WSS connection to
   the relay proxy.
2. A relay-side audio adapter translates between Protocol v0 PCM segments and
   the configured Azure Foundry Realtime session.
3. The relay addresses the selected mini-class Realtime deployment only by the
   stable logical capability name `stackchan-realtime`.
4. The adapter returns generated audio through the relay as Protocol v0
   `speak.start` / PCM / `speak.stop` frames.

The Realtime session and relay own conversational state and turn coordination.
Realtime remains hidden behind the relay; Protocol v0 is unchanged and is not
an Azure API passthrough. The concrete Azure model behind
`stackchan-realtime` is configuration selected in Issue #31. Relay-side audio
adaptation, voice activity detection (VAD), and concrete failure UX belong to
E2. Barge-in is disabled until a separate agreements PR defines Protocol v0
speak/audio overlap.

### One governed delegation boundary

Delegate only when a request needs current information, stronger reasoning,
deterministic tools, or governed memory. The explicit initial path is:

`Realtime -> task-scoped single MAF agent -> in-process AGT gate ->
stackchan-chat Responses deployment and allowlisted capabilities/tools`.

The relay turns a Realtime delegation request into one bounded task for one
MAF agent. The internal Realtime tool/function identifier is deliberately
non-normative and may change without an agreements revision. MAF receives no
raw audio and no chain-of-thought. It receives only the minimum task text or
redacted summary needed for that task plus the applicable persona constraints.
The direct Realtime session remains the owner of conversational history; the
MAF task does not become a second conversation session.

The MAF agent reaches the separately swappable stronger Responses deployment
through the stable logical capability name `stackchan-chat`. It may invoke only
capabilities and tools expressly approved for the task. MAF and AGT run in the
same initial relay process and add no separate Azure resource. A result returns
to the Realtime session as bounded text or a redacted summary for delivery on
the direct audio path.

### Fail-closed action governance

AGT governs actions, not model reasoning or response truth. The relay must
therefore use fail-closed enforcement for all of these rules:

- Load and validate a non-empty strict policy before marking delegation ready.
  Absence of a policy, permissive mode, or initialization failure leaves every
  delegated capability and tool disabled.
- Use a deny-by-default allowlist. Check every delegated capability invocation
  and every tool call immediately before execution, including each call in a
  multi-call task; approval of one call never approves a later call.
- Bound every delegated task by configured elapsed-time, model-token, and
  tool-call budgets. Exhausting any budget denies further operations.
- Treat a denial, policy timeout, or evaluation error as a denied operation.
  Never execute first and audit later.
- Record the policy/action identifier, allow-or-deny result, reason code,
  timestamp, duration, task correlation identifier, and budget counters.
  Audit events omit conversation text and every prompt, response, transcript,
  memory, and tool-argument body.

AGT does not validate factual accuracy, knowledge freshness, cross-action
intent, external-world outcomes, or physical safety. Application validation,
service isolation, least-privilege identity, and device safety remain separate
controls.

### Privacy and retention

Resolve the REQ-015 conversation-log boundary for the initial system as
follows:

- Do not persist raw audio or full transcripts by default.
- Admin-visible conversation logs contain operational metadata and only
  summaries that an approved application flow has explicitly selected and
  redacted for persistence.
- A task summary held only to complete a live or recoverable delegated task
  expires no later than 24 hours after that task ends. It is not long-term
  memory and is deleted sooner when no longer needed.
- Long-term conversational memory is out of scope until a separate accepted
  requirement defines informed consent, inspection, correction, and deletion.
- Application telemetry and AGT audit records contain no raw audio, prompt,
  response, full transcript, memory content, or tool-argument body. Metadata
  must not embed those bodies under another field name.

Issue #31 fixes platform-level retention settings; E2 implements and verifies
application persistence, TTL, deletion, and redaction behavior.

### Degraded behavior and readiness

Failures do not authorize a different provider or pipeline:

- If Realtime is unavailable, do not substitute an unapproved model, staged
  pipeline, or direct provider API. The device and relay use the provider-neutral
  degraded behavior specified in E2 and REQ-008.
- If delegation is rejected, times out, exceeds a budget, or fails, return one
  bounded, honest explanation through the still-isolated direct Realtime path;
  do not claim the requested current information, tool action, or memory result
  was obtained.
- If AGT is unavailable or errors, disable all delegation and tools. Tool-free,
  action-isolated direct conversation may remain available only when startup
  and runtime checks verify that the direct path is independent of the failed
  governance path. In that design, AGT failure is delegation-readiness failure,
  not global application-readiness failure.

Exact retry limits, user-facing error events, and reconnect/failure UX belong
to E2. Any approved model fallback belongs to Issue #31. Japanese quality,
live latency, and observed-cost acceptance belong to E4 and Issue #37.

## Superseded proposal retained as history

The 2026-07-26 proposal chose three sequential Foundry calls addressed by
`stackchan-stt`, `stackchan-chat`, and `stackchan-tts`, behind one proxy
pipeline abstraction. Realtime speech-to-speech was a later optional swap of
that abstraction, leaving firmware and Protocol v0 unchanged. Its rationale
was lower initial integration risk, per-stage latency observability, independent
model swapping, and easier isolation of Japanese STT, LLM, or TTS quality
problems. If latency missed REQ-003, it proposed streaming between stages and
ahead-of-time TTS before attempting Realtime.

That staged design was internally coherent with the raw E1, E2, and E4 plans,
but it was never accepted. The linked 2026-08-01 human decision superseded it
before merge because routine conversation should take the lower-latency direct
Realtime path and complex work should cross one governed delegation boundary.
The historical logical names `stackchan-stt` and `stackchan-tts` are not part
of the revised initial profile.

## Consequences

- Routine turns avoid the staged sequence of three model-service round trips,
  while model selection remains a relay-side configuration concern.
- The relay must bridge two different contracts: provider-neutral Protocol v0
  on the device side and the selected Realtime API on the service side.
- Complex work has one inspectable, budgeted action boundary instead of giving
  the live voice session unrestricted tools or memory.
- Direct-conversation readiness and governed-delegation readiness are distinct,
  so operators can preserve isolated conversation without presenting disabled
  tools as available.
- The privacy contract sacrifices full conversational replay and implicit
  memory in favor of data minimization and explicit future consent design.

## Explicit initial exclusions

The initial profile does not add extra model deployments, multiple agents,
MAF Workflow/Durable execution, MCP/A2A, Hosted Agents, Agent
Mesh/Hypervisor/dashboard services, arbitrary code/HTTP tools, external
writes, or implementation of news, tutoring, long-term memory, email,
purchasing, messaging, physical-action, or other product capabilities. These
require separate accepted requirements and task-scoped allowlists before
implementation.

## References

- [Human Realtime-first decision](https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/31#issuecomment-5150875484)
- `docs/agreements/requirements.md` — REQ-002, REQ-003, REQ-004, REQ-005,
  REQ-006, REQ-008, REQ-015, REQ-016, REQ-020, REQ-021, REQ-022, REQ-023
- `docs/agreements/adr/ADR-0002-overall-architecture.md`
- `docs/agreements/adr/ADR-0003-device-proxy-protocol-v0.md`
- `docs/agreements/specs/protocol-v0.md`
- [Azure GPT Realtime 2.x](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/realtime-2)
- [Realtime WebSockets](https://learn.microsoft.com/en-us/azure/foundry/openai/how-to/realtime-audio-websockets)
- [Microsoft Agent Framework overview](https://learn.microsoft.com/en-us/agent-framework/overview/)
- [Agent Framework middleware](https://learn.microsoft.com/en-us/agent-framework/agents/middleware/)
- [AGT-MAF integration](https://microsoft.github.io/agent-governance-toolkit/tutorials/34-maf-integration/)
- [AGT limitations](https://microsoft.github.io/agent-governance-toolkit/LIMITATIONS/)
- `docs/context/plan-intake/stackchan-plan/epics/E1-azure-foundation.md`
- `docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`
- `docs/context/plan-intake/stackchan-plan/epics/E4-e2e-conversation.md`
