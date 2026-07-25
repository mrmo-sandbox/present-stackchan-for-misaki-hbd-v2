# Device–Proxy Protocol v0 (normative)

Normative companion spec to
`docs/agreements/adr/ADR-0003-device-proxy-protocol-v0.md`. Status follows
that ADR: **proposed** until a human merges the agreements PR containing
both (decision Q3 — agents never flip status). Epics E2 (proxy) and E3
(firmware) cite this file directly; the per-message headings below are
stable anchors for task references.

Derived from: the protocol inventory and constraints in
`docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md` and
`docs/context/plan-intake/stackchan-plan/epics/E3-firmware-mvp.md`, and
REQ-005 / REQ-007 / REQ-008 in `docs/agreements/requirements.md`. Items the
sources do not fix are marked **[confirm: E2]** / **[confirm: E3]** and
listed again in §Open points — they are deliberate gaps, not oversights.

## 1. Transport

- One WebSocket connection over TLS (**WSS**) per device, initiated by the
  device to the relay proxy (ADR-0002). The URL path is deployment
  configuration, not part of this protocol. **[confirm: E2]**
- **Text frames** carry exactly one JSON object each — a control message
  with a mandatory `"type"` field (inventory in §4).
- **Binary frames** carry raw audio only (§3). A binary frame is valid only
  inside an open audio segment (§4.4, §4.6); a binary frame outside one is
  a protocol error.
- Unknown JSON fields must be ignored by both sides; an unknown `"type"` is
  a protocol error. This is the v0 forward-compatibility rule.

## 2. Versioning

The protocol version is negotiated once per connection: `hello` carries
`"v": 0`. A proxy that does not support the offered version replies with an
`error` (code `unsupported_version`) and closes. Future revisions bump `v`;
v0 devices keep working until the proxy drops v0 support via an agreements
change. No other message carries a version field.

## 3. Audio format

All audio in both directions is **PCM16, 16 000 Hz, mono** (E3 epic body;
mono per ADR-0003): raw signed 16-bit PCM samples, no container, no
compression. Byte order is provisionally **little-endian**
**[confirm: E3]** — no source fixes it; E3 confirms against the actual
mic/speaker path and this line is updated by an agreements PR if wrong.
Binary frame size (samples per frame) is not fixed by v0
**[confirm: E2, E3]**; receivers must accept any frame size and consume
frames in arrival order.

## 4. Messages

Direction key: D→P = device to proxy, P→D = proxy to device.

### 4.1 `hello` (D→P)

First frame after connect, always. Authenticates the device with its
per-device key — the only credential the device holds (REQ-005); keys are
issued and revoked per device (REQ-007). No other message is valid before
the proxy's answer.

```json
{
  "type": "hello",
  "v": 0,
  "device_id": "stackchan-001",
  "device_key": "<per-device secret>"
}
```

`device_id` identifies which key to check; identifier format
**[confirm: E2]**.

### 4.2 `hello.ok` (P→D)

Positive handshake result; the session is now active. On failure the proxy
sends `error` (§4.9) and closes instead — REQ-007's revocation test
observes exactly that rejection. (`hello.ok` and `error` are v0 additions
not named in the raw epic inventory — see ADR-0003, Consequences;
**[confirm: E2]**.)

```json
{
  "type": "hello.ok"
}
```

### 4.3 `audio.start` (D→P)

Opens an upstream audio segment: the user started speaking. Carries no
fields; the audio format is fixed by §3, not negotiated.

```json
{
  "type": "audio.start"
}
```

### 4.4 Upstream binary audio (D→P, binary frames)

Between `audio.start` and `audio.stop`, every binary frame is captured
microphone audio in the §3 format. One upstream segment may be open at a
time; a second `audio.start` before `audio.stop` is a protocol error.

### 4.5 `audio.stop` (D→P)

Closes the upstream segment: the utterance ended. The proxy then runs the
conversation pipeline (ADR-0004) and answers with a speak segment.

```json
{
  "type": "audio.stop"
}
```

### 4.6 `speak.start` (P→D) and downstream binary audio

Opens a downstream audio segment; until `speak.stop`, every binary frame is
response audio in the §3 format, played by the device in arrival order.
`face` / `servo` messages may be interleaved with downstream binary frames
(the proxy animates the device while it speaks — E2 epic body). Overlap
rules between an open speak segment and a new `audio.start` (barge-in) are
not defined in v0 **[confirm: E2, E4 integration]**.

```json
{
  "type": "speak.start"
}
```

### 4.7 `speak.stop` (P→D)

Closes the downstream segment.

```json
{
  "type": "speak.stop"
}
```

### 4.8 `face` (P→D)

Sets the device's facial expression. The expression vocabulary is an open
string set in v0 — it depends on BSP capabilities **[confirm: E3]**. The
only reserved behavior: while disconnected the device shows its local
standby expression on its own (§6); `face` messages exist only on a live
connection.

```json
{
  "type": "face",
  "expression": "neutral"
}
```

### 4.9 `servo` (P→D)

Moves the head servo. `y` is the Y-axis target angle in degrees; the valid
range is **5–85°**, a hardware constraint recorded in the E3 epic body. The
device must clamp or reject out-of-range values (never drive past the
constraint). Whether v0 also needs an X axis is open **[confirm: E3]**.

```json
{
  "type": "servo",
  "y": 45
}
```

### 4.10 `error` (P→D)

Reports a failure. After a fatal error (both initial codes are fatal) the
proxy closes the connection. Initial code set — inventory to be extended in
E2 **[confirm: E2]**:

| Code | Meaning |
|---|---|
| `auth_failed` | `hello` rejected: unknown device, bad or revoked key (REQ-007) |
| `unsupported_version` | `hello.v` not supported by this proxy (§2) |
| `protocol_error` | Frame violated this spec (binary outside a segment, unknown type, double `audio.start`, non-`hello` first frame) |

```json
{
  "type": "error",
  "code": "auth_failed",
  "message": "device key rejected"
}
```

## 5. Keepalive

The device sends a WebSocket protocol-level **ping** control frame every
**30 seconds**; the proxy answers with pong per the WebSocket protocol.
Rationale: the Container Apps ingress idle timeout is 240 seconds (E2 epic
body — "30秒ping … CAの240秒タイムアウト対策"). Keepalive lives at the
WebSocket level, not in the JSON message set; if the E3 firmware WebSocket
stack cannot emit protocol-level pings, a JSON ping message is added by an
agreements PR **[confirm: E2, E3]**. A device that misses pong responses
should treat the connection as dead and enter §6.

## 6. Reconnection and degraded mode

On disconnect — network loss, proxy restart, missed pongs, fatal `error` —
the device (REQ-008, E3 epic body):

1. Shows its local **standby facial expression** and stops interactive
   behavior (degraded mode; see `docs/agreements/glossary.md`).
2. Reconnects automatically with **exponential backoff**. Backoff
   parameters (initial interval, factor, cap) are firmware configuration
   fixed in E3 **[confirm: E3]**; the rule that backoff is exponential is
   normative here.
3. Every reconnect is a fresh session: it starts again at `hello` (§4.1).
   No conversation state or in-flight audio survives a reconnect; partial
   segments on either side are simply dropped.

An `auth_failed` error is still followed by backoff reconnection (the key
may have been rotated and re-provisioned); the device never retries in a
tight loop.

## 7. Out of scope for v0

- BLE provisioning (E5 territory; a future protocol revision).
- Text-based turns; realtime-API passthrough (stays behind the proxy
  pipeline abstraction — ADR-0004; invisible on this wire).
- Device→proxy telemetry (battery, status): state fan-out to clients rides
  Web PubSub (REQ-014, ADR-0002); whether the device reports state over
  this WebSocket or another path is decided in E2/E3 planning, not v0.

## 8. Open points (consolidated)

| # | Open point | Confirm in |
|---|---|---|
| 1 | URL path / endpoint configuration | E2 |
| 2 | `device_id` format and issuance | E2 |
| 3 | `hello.ok` / `error` additions confirmed against proxy implementation | E2 |
| 4 | Binary frame size | E2, E3 |
| 5 | PCM byte order (little-endian assumed) | E3 |
| 6 | Barge-in / segment-overlap rules | E2, E4 |
| 7 | `face` expression vocabulary | E3 |
| 8 | Servo X axis (Y-only in v0) | E3 |
| 9 | Error-code inventory beyond the initial three | E2 |
| 10 | Protocol-level ping feasibility in firmware | E2, E3 |
| 11 | Backoff parameters | E3 |
| 12 | Device state/telemetry path | E2, E3 |

## References

- `docs/agreements/adr/ADR-0003-device-proxy-protocol-v0.md` — the decision
  this spec implements
- `docs/agreements/requirements.md` — REQ-005, REQ-007, REQ-008
- `docs/agreements/glossary.md` — "Protocol v0", "Device key", "Degraded
  mode"
- `docs/context/plan-intake/stackchan-plan/epics/E2-proxy-mvp.md`
- `docs/context/plan-intake/stackchan-plan/epics/E3-firmware-mvp.md`
- `docs/context/azure-foundry/seed-from-plan-intake.md`,
  `docs/context/stackchan-hw/seed-from-plan-intake.md` — verbatim excerpts
  backing the inventory
