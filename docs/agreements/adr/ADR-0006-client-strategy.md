# ADR-0006: Client strategy — iOS app primary, LINE mini-app as a subset

- **Status:** proposed
- **Date:** 2026-07-26
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

Two management clients are required: an iOS app providing BLE provisioning,
settings changes, conversation-log viewing, and remote control (REQ-009),
and a LINE mini-app providing QR linking, settings changes, log viewing,
and remote control as an explicit subset of the iOS app (REQ-010). Mini-app
limitations must never cut or delay iOS features, with a feature-parity
table as the single source of truth (REQ-011). Non-goals bound the space:
no native Android app — Android is covered by the mini-app plus an external
browser (NG-005); no public App Store release — private distribution, with
the concrete method decided before E5 and tracked in issue #26 (NG-007);
the mini-app operates unverified (NG-003).

The raw epic bodies fix the concrete shapes: E5 — a SwiftUI-native iOS
alpha, LINE login, BLE provisioning taking a factory-fresh device to a
working conversation, and an OpenAPI-first management API whose generated
clients are shared between iOS and the mini-app; E6 — an unverified LIFF
mini-app with QR linking via `liff.scanCodeV2()` (reading the QR shown on
the device LCD), a Web PubSub realtime dashboard (REQ-014), and
external-browser fallback checks. Notifications split by client: APNs for
iOS, LINE Messaging API for mini-app users (REQ-013). Sources:
`docs/context/plan-intake/stackchan-plan/epics/E5-mgmt-api-ios-alpha.md`,
`docs/context/plan-intake/stackchan-plan/epics/E6-line-miniapp-alpha.md`,
`docs/context/line-miniapp/seed-from-plan-intake.md`.

The conflict: two clients on one hobby schedule invites either duplicated
effort or silent feature drift between them.

## Decision

The iOS app (SwiftUI native) is the primary administration client and the
only client with the full feature set, including BLE provisioning
(REQ-009). The LINE mini-app is a strict feature subset (REQ-010) — its
platform limitations never justify cutting or delaying an iOS feature, and
the feature-parity table is the single source of truth for the subset
relationship (REQ-011). Both clients consume one management API defined
OpenAPI-first, with generated API clients shared between them (E5 body), and
both subscribe to the shared Web PubSub state channel (REQ-014). Android
gets no native app: mini-app plus external browser covers it (NG-005). The
iOS app is distributed privately, never via public App Store release
(NG-007); the mini-app launches unverified (NG-003).

## Consequences

- Easier: one API contract feeds both clients (generated clients keep them
  from drifting); scope control is mechanical — a proposed mini-app-only
  feature is by definition out of scope until it exists on iOS.
- Harder: every management feature is specified twice at the UI level; the
  parity table (REQ-011) must actually be maintained — it does not exist
  yet (noted in `docs/context/line-miniapp/INDEX.md`) and E6 owns updating
  it; provisioning is iOS-only, so initial device setup requires the
  administrator's iPhone (acceptable: the administrator is the maker,
  NG-002).
- Device-side prerequisites land early: the QR-linking flow needs the
  device LCD QR screen from E3 (E3 body, "REQ-010の素地"), and BLE
  provisioning needs an E5-phase firmware supplement (E5 body).
- Open points, thin evidence (the LINE mini-app survey is not yet exported
  — `docs/context/line-miniapp/INDEX.md`):
  - Confirm in E3: QR payload content and format for the linking flow (no
    source specifies it; it must be settled when the LCD QR screen is
    built, together with the linking endpoint it points at).
  - Confirm in E5/E6 (detail level): parity-table location and format
    (REQ-011); the concrete private-distribution method (tracked in #26,
    decided before E5 per NG-007); external-browser fallback behavior for
    scanCode-dependent flows (E6 body names the check, not the behavior).

## References

- `docs/agreements/requirements.md` — REQ-009, REQ-010, REQ-011, REQ-013,
  REQ-014
- `docs/agreements/non-goals.md` — NG-002, NG-003, NG-005, NG-007
- `docs/agreements/glossary.md` — "LINE mini-app", "LIFF", "QR linking",
  "Feature-parity table", "BLE provisioning"
- `docs/context/plan-intake/stackchan-plan/epics/E5-mgmt-api-ios-alpha.md`
  (raw numbering: the epic's "ADR-0005（クライアント戦略）"; renumbered per
  ADR-0001)
- `docs/context/plan-intake/stackchan-plan/epics/E6-line-miniapp-alpha.md`
- `docs/context/plan-intake/stackchan-plan/epics/E3-firmware-mvp.md` — LCD
  QR screen prerequisite
- `docs/context/line-miniapp/seed-from-plan-intake.md`,
  `docs/context/line-miniapp/INDEX.md`
- Issue #26 — NG-007 distribution-method follow-up
- ADR-0002 (overall architecture), ADR-0005 (authentication)
