# ADR-0003: Device–proxy protocol v0

- **Status:** proposed
- **Date:** 2026-07-26
- **Supersedes:** none

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

Epics E2 (relay proxy) and E3 (firmware) are built by different sessions in
parallel and meet only at the wire. Both raw epic bodies already commit to
the same message inventory — `hello / audio.start / PCM binary / audio.stop`
upstream and `speak.start / PCM / speak.stop` downstream, plus `face` and
`servo` events — a 30-second ping keepalive against the Container Apps
240-second idle timeout, PCM16/16 kHz audio, and exponential-backoff
reconnection with a standby facial expression while disconnected (REQ-008).
The device authenticates with its per-device key (REQ-005), which must be
issuable and revocable per device (REQ-007). Sources:
`docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`,
`docs/context/plan-intake/stackchan-plan/epics/E3-firmware-mvp.md`,
`docs/context/azure-foundry/seed-from-plan-intake.md`,
`docs/context/stackchan-hw/seed-from-plan-intake.md`, and the "Protocol v0"
entry in `docs/agreements/glossary.md`.

Without a single normative document, E2 and E3 would each interpret that
inventory independently and discover mismatches only at E4 integration.

## Decision

Fix protocol v0 as a WSS protocol with JSON text frames for control messages
and raw binary frames for audio, exactly as specified in the normative
companion spec **`docs/agreements/specs/protocol-v0.md`** — that file, not
this ADR, is the citation target for E2/E3 implementation tasks. Headline
rules decided here: a single WSS connection per device; a `hello` handshake
carrying the protocol version and the per-device key as the only
authentication (REQ-005, REQ-007); audio in both directions as PCM16 /
16 kHz / mono binary frames bracketed by start/stop control messages;
`face` and `servo` as proxy-to-device control events; a 30-second keepalive
ping (Container Apps 240 s idle timeout); and device-side reconnection with
exponential backoff plus degraded standby-face behavior while disconnected
(REQ-008). The version field makes later revisions (v1+) negotiable without
breaking v0 firmware.

## Consequences

- Easier: E2 and E3 can proceed in parallel against one contract
  (`docs/agreements/specs/protocol-v0.md`), and E4 integration failures
  become spec-conformance questions rather than design debates.
- Harder: protocol changes now require an agreements PR (spec + possibly a
  superseding ADR), not an ad-hoc code change on either side.
- The spec deliberately adds two minimal messages the raw inventory does not
  name — `hello.ok` and `error` — because REQ-007's verification (a
  connection-rejection test after key revocation) requires an observable
  accept/reject outcome. They are marked as v0 additions in the spec and
  must be confirmed in E2.
- Open points to confirm in E2 (proxy): binary audio frame/chunk size;
  error-code inventory beyond the initial minimal set; whether keepalive
  stays at the WebSocket protocol level (current decision) or becomes a JSON
  message.
- Open points to confirm in E3 (firmware/device): PCM byte order (the spec
  provisionally assumes little-endian — flagged there, no source fixes it);
  exponential-backoff parameters (initial/max interval); the facial
  `expression` vocabulary (depends on BSP capabilities); whether the servo
  protocol needs an X axis in addition to the Y axis whose 5–85° constraint
  the E3 body records.
- Out of protocol v0 (unchanged by this ADR): BLE provisioning (E5
  territory), text-based turns, realtime-API passthrough (ADR-0004 keeps
  that behind the proxy's pipeline abstraction, invisible to this protocol).

## References

- `docs/agreements/specs/protocol-v0.md` — normative companion spec
  (machine-readable message schema)
- `docs/agreements/requirements.md` — REQ-005, REQ-007, REQ-008
- `docs/agreements/glossary.md` — "Protocol v0", "Device key",
  "Degraded mode"
- `docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md` — proxy
  message inventory, 30 s ping vs 240 s timeout (raw numbering: this is the
  epic's "ADR-0002（プロトコル）"; renumbered per ADR-0001)
- `docs/context/plan-intake/stackchan-plan/epics/E3-firmware-mvp.md` —
  device-side inventory, PCM16/16 kHz, backoff + standby face, servo Y-axis
  5–85° constraint
- `docs/context/azure-foundry/seed-from-plan-intake.md`,
  `docs/context/stackchan-hw/seed-from-plan-intake.md` — verbatim excerpts
- ADR-0002 (overall architecture), ADR-0004 (audio pipeline)
