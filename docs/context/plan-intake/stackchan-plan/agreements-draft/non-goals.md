# Non-goals

Explicit "we will not" statements — the cheapest scope-creep guard. Agents
treat these as hard boundaries; changing one requires an agreements PR.

<!-- 初版ドラフト。E0の蒸留PRでレビューのこと。 -->

- NG-001: 2026-07-26 は納期対象にしない。目標は 2027-07-26 のみ。(Source: 発案者確認 2026-07-18, docs/context/design-sessions/2026-07-claude-planning/)
- NG-002: 多世帯・多ユーザー向けのSaaS化はしない。管理者=製作者、主利用者=みさきさん＋家族の範囲とする。(Source: 同上)
- NG-003: LINEミニアプリの「認証済み」審査取得はMVPの必須条件にしない。未認証で運用開始する（審査は任意のstretch）。(Source: docs/context/line-miniapp/)
- NG-004: アプリ内課金・収益化は行わない。(Source: docs/context/design-sessions/2026-07-claude-planning/)
- NG-005: Androidネイティブアプリは作らない。Android利用はLINEミニアプリ＋外部ブラウザで代替する。(Source: 同上)
- NG-006: 出荷時ファームウェア（XiaoZhiエコシステム）との互換維持はしない。カスタムファームに置き換える（復元手順は REQ-018 で担保）。(Source: docs/context/stackchan-hw/)
- NG-007: App Store への一般公開はしない。TestFlight等の私的配布で足りるものとする。【要確認：配布方式は E5 開始前に発案者と確定】(Source: docs/context/design-sessions/2026-07-claude-planning/)
- NG-008: 5GHz Wi-Fi 対応はしない（ESP32-S3のハードウェア制約）。(Source: docs/context/stackchan-hw/)
