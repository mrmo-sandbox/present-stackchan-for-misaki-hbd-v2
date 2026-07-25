# Glossary

Project-specific vocabulary. Agents misname what humans leave undefined —
define terms here once and cite them.

| Term | Definition | Source |
|---|---|---|
| StackChan | The palm-sized companion robot being gifted — an M5Stack K151 kit (CoreS3-based) that will run this project's custom firmware | docs/context/stackchan-hw/seed-from-plan-intake.md |
| Device key | The per-device secret used in the `hello` handshake with the relay proxy; the only credential the device holds (no Azure credentials on the device), issued and revocable per device | docs/context/stackchan-hw/seed-from-plan-intake.md |
| Relay proxy | The cloud service between the device and Azure: it terminates the device WebSocket, runs the STT → LLM → TTS pipeline, and calls Azure AI Foundry keylessly | docs/context/azure-foundry/seed-from-plan-intake.md |
| Protocol v0 | The WebSocket message protocol between device and relay proxy: hello / audio.start / PCM binary / audio.stop → speak.start / PCM / speak.stop, plus face and servo events | docs/context/azure-foundry/seed-from-plan-intake.md |
| Degraded mode | Safe device behavior while disconnected from the proxy: the device shows a standby facial expression instead of interactive behavior while exponential-backoff reconnection runs | docs/context/stackchan-hw/seed-from-plan-intake.md |
| LINE mini-app | The management web app running inside LINE (LIFF runtime); a feature subset of the iOS app | docs/context/line-miniapp/seed-from-plan-intake.md |
| LIFF | LINE Front-end Framework — the runtime/browser the mini-app executes in (LIFF browser on iOS/Android; scanCode APIs are unavailable in external browsers) | docs/context/line-miniapp/seed-from-plan-intake.md |
| Verified mini-app | LINE's reviewed "verified" status for mini-apps; this project starts operation unverified (NG-003) and treats the review as an optional stretch goal | docs/context/line-miniapp/seed-from-plan-intake.md |
| Allowlist | The explicit list of LINE accounts granted administrator access; LINE ID-token verification plus this allowlist is the authentication model shared by the iOS app and the mini-app (REQ-012) | docs/context/plan-intake/stackchan-plan/agreements-draft/requirements.md |
| QR linking | The flow that binds a device to the account: the device shows a QR code on its LCD and the mini-app scans it (`liff.scanCodeV2()`) to complete the link via the cloud | docs/context/line-miniapp/seed-from-plan-intake.md |
| Feature-parity table | The single-source table comparing iOS app and mini-app features, maintained so mini-app limitations never shrink or delay the iOS app (REQ-011) | docs/context/line-miniapp/INDEX.md |
| XiaoZhi ecosystem | The factory-firmware ecosystem the K151 ships with; compatibility with it is a non-goal (NG-006), but a documented, demonstrated restore path is required (REQ-018) | docs/context/stackchan-hw/seed-from-plan-intake.md |
| BLE provisioning | Initial device setup from the iOS app over Bluetooth LE: writing Wi-Fi settings and the device key (REQ-009) | docs/context/plan-intake/stackchan-plan/agreements-draft/requirements.md |
