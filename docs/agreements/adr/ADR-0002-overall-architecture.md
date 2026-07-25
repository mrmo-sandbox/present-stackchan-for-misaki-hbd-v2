# ADR-0002: Overall architecture — device, Azure relay proxy, model services

- **Status:** proposed
- **Date:** 2026-07-26
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

The gift is a single StackChan (M5Stack K151, CoreS3-based) that must hold a
Japanese voice conversation (REQ-002) while keeping every Azure credential off
the device (REQ-005). The conversation LLM must be reachable only through
Azure AI Foundry deployments, swappable without firmware changes (REQ-004),
and service-to-service authentication must be keyless via Entra ID Managed
Identity (REQ-006). Logs and settings live in Cosmos DB with admin-only
access (REQ-015), secrets live in Key Vault (REQ-016), and device state is
fanned out to all clients over a shared Azure Web PubSub channel (REQ-014).
This is a single-household system, not a SaaS (NG-002), so one environment
serving as both prod and dev is acceptable.

The raw plan bundle already sketches this shape: the E1 epic body lists the
Azure resource set (Resource Group, Log Analytics, Application Insights,
Key Vault, Cosmos DB, Container Apps environment, Web PubSub, AI Foundry)
provisioned via Bicep with logical model deployment names, and the E2 epic
body places a relay proxy on Container Apps terminating device WebSocket
connections. Sources:
`docs/context/azure-foundry/seed-from-plan-intake.md` (E1 body, REQ rows),
`docs/context/plan-intake/stackchan-plan/epics/E1-azure-foundation.md`,
`docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`.

The conflict forcing a decision: the device is a constrained ESP32-S3 that
cannot safely hold cloud credentials or track Azure API changes, yet the
model stack must remain swappable and observable. Something must sit between
them.

## Decision

Adopt a three-tier architecture: the StackChan device (custom firmware)
connects exclusively to a relay proxy over a single WebSocket (WSS)
connection, authenticated by its per-device key; the relay proxy runs on
Azure Container Apps, terminates device connections, runs the conversation
pipeline, and is the only component that calls Azure AI Foundry — keylessly,
via Managed Identity. Supporting Azure services surround the proxy: Cosmos DB
(conversation logs, settings), Key Vault (secrets), Web PubSub (device-state
fan-out to clients), Log Analytics + Application Insights (observability),
all provisioned from Bicep as one environment (prod doubling as dev, per the
E1 phase outline). Management clients (the iOS app and the LINE mini-app,
ADR-0006) talk to a management API and subscribe to Web PubSub; they never
talk to the device directly except for local provisioning flows (REQ-009).

The device therefore holds exactly one secret — its per-device key
(REQ-005, REQ-007) — and every model swap is a proxy-side deployment-name or
configuration change (REQ-004).

## Consequences

- Easier: firmware stays small and stable; model and persona changes are
  cloud-side only (REQ-004); credential audit reduces to "device key on the
  device, everything else in Key Vault / Managed Identity" (REQ-005,
  REQ-006, REQ-016).
- Harder: the proxy is a single critical component; the device must degrade
  safely when it is unreachable (REQ-008, spec:
  `docs/agreements/specs/protocol-v0.md`), and proxy availability limits
  conversation availability. Accepted for a single-household system (NG-002).
- The device–proxy wire contract needs its own decision and normative spec —
  split out as ADR-0003.
- Open points to confirm in E1 (thin evidence — the detailed Azure/Foundry
  design notes named in
  `docs/context/plan-intake/stackchan-plan/HANDOFF.md` are not yet exported
  to `docs/context/azure-foundry/`, see its INDEX):
  - Resource SKUs, region, and the monthly budget threshold (REQ-017 is
    provisional until E1 fixes the number).
  - Idempotent Bicep layout and the exact RBAC role set for the proxy's
    Managed Identity.
  - Where the management API (E5 scope) is hosted — the same Container Apps
    environment is the working assumption, not yet a sourced decision.
- Open point to confirm in E2: proxy scaling/concurrency settings for a
  single-device household (no load figures exist in the sources).

## References

- `docs/agreements/requirements.md` — REQ-002, REQ-004, REQ-005, REQ-006,
  REQ-007, REQ-008, REQ-014, REQ-015, REQ-016, REQ-017
- `docs/agreements/non-goals.md` — NG-002
- `docs/context/azure-foundry/seed-from-plan-intake.md` — E1 body and
  Azure-facing REQ rows (verbatim)
- `docs/context/azure-foundry/INDEX.md` — records that the full
  Azure/Foundry design notes are still to be collected
- `docs/context/plan-intake/stackchan-plan/epics/E1-azure-foundation.md`
- `docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`
- `docs/context/plan-intake/stackchan-plan/HANDOFF.md`
- ADR-0003 (device–proxy protocol), ADR-0004 (audio pipeline),
  ADR-0005 (authentication), ADR-0006 (client strategy)
