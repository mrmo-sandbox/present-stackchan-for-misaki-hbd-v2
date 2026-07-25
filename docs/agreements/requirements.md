# Requirements

One row per verifiable requirement. IDs are permanent: never reuse or
renumber; supersede instead (`Status: superseded by REQ-###`). Every `REQ`
must be provable by a command or an observable behavior
(`.github/skills/context-distillation/SKILL.md`, Quality bar).

Distilled by T-E0-7 (#18) from
`docs/context/plan-intake/stackchan-plan/agreements-draft/requirements.md`;
the human merge of the distillation PR is the agreement.

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-001 | The gift is ready on 2027-07-26: an initialized physical device, an instruction card, and the outer casing are all prepared, and in a fresh environment (Wi-Fi not yet registered) setup completes from power-on to a working voice conversation within 10 minutes | docs/context/design-sessions/2026-07-claude-planning/ | Timed measurement record from the E8 final rehearsal | accepted |
| REQ-002 | Japanese voice conversation works on the physical StackChan (M5Stack K151): the user speaks and the spoken response is played back | docs/context/design-sessions/2026-07-claude-planning/ | E4 on-device end-to-end test and demo video | accepted |
| REQ-003 | Response latency (end of user utterance to start of response-audio playback) is P50 ≤ 3.0 s / P95 ≤ 6.0 s (provisional figures; measured in E4, and this agreement is revised if needed) | docs/context/design-sessions/2026-07-claude-planning/ | Aggregated report from relay-proxy measurement logs | provisional (re-measure in E4; revise if needed) |
| REQ-004 | The conversation LLM is reached only via Azure AI Foundry deployments, and the model can be swapped (deployment-name / configuration change) without any device firmware change | docs/context/design-sessions/2026-07-claude-planning/ + docs/context/azure-foundry/ | Model-swap test with no service interruption | accepted |
| REQ-005 | The device holds no Azure credentials of any kind; the only secret it holds is its per-device key | docs/context/design-sessions/2026-07-claude-planning/ | Firmware code review plus inspection of flash contents | accepted |
| REQ-006 | Proxy-to-Foundry authentication is keyless, via Entra ID (Managed Identity) | docs/context/azure-foundry/ | Bicep/configuration review; confirmation that no API keys are used | accepted |
| REQ-007 | Device keys can be issued per device and revoked per device | docs/context/design-sessions/2026-07-claude-planning/ | Connection-rejection test after revocation | accepted |
| REQ-008 | On WebSocket disconnection the device reconnects automatically with exponential backoff, and while disconnected it behaves safely in degraded mode (standby facial expression) | docs/context/design-sessions/2026-07-claude-planning/ | Disconnection and cloud-outage tests | accepted |
| REQ-009 | The iOS app provides BLE provisioning (Wi-Fi setup plus device-key write), settings changes, conversation-log viewing, and remote control | docs/context/design-sessions/2026-07-claude-planning/ | E5 on-device end-to-end test | accepted |
| REQ-010 | The LINE mini-app provides QR linking, settings changes, conversation-log viewing, and remote control (a subset of the iOS app) | docs/context/line-miniapp/ | E6 on-device end-to-end test (LIFF browser on iOS/Android) | accepted |
| REQ-011 | Mini-app limitations are never a reason to cut or delay iOS app features; the feature-parity table is maintained as the single source of truth | docs/context/design-sessions/2026-07-claude-planning/ | Parity-table diff review at E6 completion | accepted |
| REQ-012 | Administrator authentication uses a LINE account (ID-token verification) plus an allowlist, shared across the iOS app and the mini-app | docs/context/design-sessions/2026-07-claude-planning/ | Rejection test with a non-allowlisted user | accepted |
| REQ-013 | Anomaly notifications (offline, low battery) reach iOS via APNs and mini-app users via the LINE Messaging API | docs/context/line-miniapp/ | E7 live notification-firing test | accepted |
| REQ-014 | Real-time distribution of device state uses a shared channel (Azure Web PubSub) that every client can subscribe to | docs/context/azure-foundry/ | Concurrent multi-client subscription test | accepted |
| REQ-015 | Conversation logs and settings are stored in Cosmos DB and are viewable by administrators only | docs/context/design-sessions/2026-07-claude-planning/ | Rejection test for unauthorized access | accepted |
| REQ-016 | Secrets are managed in Key Vault; the repository, the firmware, and the clients contain no secrets | docs/context/design-sessions/2026-07-claude-planning/ | Secret scan plus configuration review | accepted |
| REQ-017 | A budget alert is configured on the monthly running cost (threshold decided in E1, after which this table is updated) | docs/context/design-sessions/2026-07-claude-planning/ | Alert-firing test and monthly cost report | provisional (threshold decided in E1; update this row) |
| REQ-018 | The procedure for restoring the factory firmware is documented and demonstrated at least once | docs/context/stackchan-hw/ | Record of the restore rehearsal | accepted |
| REQ-019 | Birthday presentation features are included: first-boot message, dedicated persona, and anniversary-aware responses | docs/context/design-sessions/2026-07-claude-planning/ | E8 demo check | accepted |
