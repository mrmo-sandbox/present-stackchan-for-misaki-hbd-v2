# Non-goals

Explicit "we will not" statements — the cheapest scope-creep guard. Agents
treat these as hard boundaries; changing one requires an agreements PR.

Distilled by T-E0-7 (#18) from
`docs/context/plan-intake/stackchan-plan/agreements-draft/non-goals.md`;
the human merge of the distillation PR is the agreement.

- NG-001: We will not treat 2026-07-26 as a delivery date; the only target
  is 2027-07-26. (Source: originator confirmation 2026-07-18, recorded in
  docs/context/design-sessions/2026-07-claude-planning/)
- NG-002: We will not turn this into a SaaS for multiple households or
  users; the administrator is the maker, and the primary users are Misaki
  plus her family. (Source:
  docs/context/design-sessions/2026-07-claude-planning/)
- NG-003: We will not make LINE's "verified" mini-app review status a
  mandatory MVP condition; operation starts unverified (the review is an
  optional stretch goal). (Source: docs/context/line-miniapp/)
- NG-004: We will not implement in-app purchases or any monetization.
  (Source: docs/context/design-sessions/2026-07-claude-planning/)
- NG-005: We will not build a native Android app; Android use is covered by
  the LINE mini-app plus an external browser. (Source:
  docs/context/design-sessions/2026-07-claude-planning/)
- NG-006: We will not maintain compatibility with the factory firmware
  (XiaoZhi ecosystem); it is replaced by custom firmware (the restore path
  is guaranteed by REQ-018). (Source: docs/context/stackchan-hw/)
- NG-007: We will not release the iOS app publicly on the App Store;
  private distribution (such as TestFlight) suffices. The distribution
  method is decided before E5 — tracked in #26. (Source:
  docs/context/design-sessions/2026-07-claude-planning/)
- NG-008: We will not support 5 GHz Wi-Fi (an ESP32-S3 hardware
  constraint). (Source: docs/context/stackchan-hw/)
