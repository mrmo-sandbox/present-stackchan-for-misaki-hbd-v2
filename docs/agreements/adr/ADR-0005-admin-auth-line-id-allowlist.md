# ADR-0005: Authentication — LINE ID token plus admin allowlist

- **Status:** proposed
- **Date:** 2026-07-26
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

Administrator authentication must use a LINE account (ID-token
verification) plus an allowlist, shared across the iOS app and the LINE
mini-app (REQ-012). Conversation logs and settings are admin-only
(REQ-015). This is a single-household system whose administrator is the
maker (NG-002), so a heavyweight identity platform is unjustified — but
"family only" must still be enforced.

The raw epic bodies fix the mechanism on both clients: E5 has the
management API validating LINE ID tokens against an administrator allowlist
and the iOS app logging in with the LINE SDK; E6 has the mini-app using
LIFF initialization and auto-login, then authorizing against the same
management API with the ID token. Meanwhile the machine plane is already
decided elsewhere: devices authenticate with a per-device key only
(REQ-005, REQ-007; ADR-0003), and service-to-service calls are keyless via
Managed Identity (REQ-006; ADR-0002). Secrets belong in Key Vault, never in
repo, firmware, or clients (REQ-016). Sources:
`docs/context/plan-intake/stackchan-plan/epics/E5-mgmt-api-ios-alpha.md`,
`docs/context/plan-intake/stackchan-plan/epics/E6-line-miniapp-alpha.md`,
`docs/context/line-miniapp/seed-from-plan-intake.md`,
`docs/agreements/glossary.md` ("Allowlist").

## Decision

Authentication has exactly three planes, and no other identity mechanism is
introduced: (1) **human administrators** authenticate with their LINE
account — the client obtains a LINE ID token (LINE SDK login on iOS, LIFF
auto-login in the mini-app), the management API verifies the token and then
authorizes the LINE user ID against an explicit administrator allowlist —
one identical mechanism for both clients (REQ-012); (2) **devices**
authenticate to the relay proxy with their per-device key only (REQ-005,
REQ-007, ADR-0003); (3) **services** authenticate to Azure services
keylessly via Entra ID Managed Identity (REQ-006). Allowlist membership is
the sole authorization model in v0 — an allowlisted LINE account is an
administrator; everyone else is rejected (REQ-012's verification is exactly
that rejection test).

## Consequences

- Easier: no password store, no bespoke account system, no per-client auth
  divergence — the mini-app and iOS app share one verification path and one
  allowlist; family members already have LINE accounts.
- Harder: administration is impossible without LINE (accepted — LINE is
  already a hard dependency of REQ-010/REQ-013); LINE channel outages block
  admin login (the device conversation path does not depend on this plane).
- No role hierarchy exists in v0; if "family member, not admin" viewing
  roles are ever wanted, that is a REQ change plus a superseding ADR, not a
  quiet extension.
- Open points, thin evidence (the LINE mini-app survey named in
  `docs/context/line-miniapp/INDEX.md` is not yet exported; no
  ID-token-verification specifics exist in the sources):
  - Confirm in E1: where the allowlist and LINE channel configuration are
    stored (Cosmos DB settings vs Key Vault secret — REQ-015/REQ-016 imply
    the split but no source fixes it); what the E1 Bicep must provision for
    it.
  - Confirm in E2: whether the proxy needs any admin-plane awareness at all
    (current assumption: none — admin traffic terminates at the management
    API, per ADR-0002).
  - Confirm in E5/E6 (detail level): ID-token verification endpoint and
    audience/channel-ID handling for the two clients, token refresh
    behavior, allowlist management UX. These are implementation details of
    the decided mechanism, not open architecture.

## References

- `docs/agreements/requirements.md` — REQ-005, REQ-006, REQ-007, REQ-012,
  REQ-015, REQ-016
- `docs/agreements/non-goals.md` — NG-002
- `docs/agreements/glossary.md` — "Allowlist", "Device key", "LIFF"
- `docs/context/plan-intake/stackchan-plan/epics/E5-mgmt-api-ios-alpha.md`
  (raw numbering: the epic's "ADR-0004（認証）"; renumbered per ADR-0001)
- `docs/context/plan-intake/stackchan-plan/epics/E6-line-miniapp-alpha.md`
- `docs/context/line-miniapp/seed-from-plan-intake.md`,
  `docs/context/line-miniapp/INDEX.md`
- ADR-0002 (overall architecture), ADR-0003 (device–proxy protocol),
  ADR-0006 (client strategy)
