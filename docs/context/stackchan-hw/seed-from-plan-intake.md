---
source: docs/context/plan-intake/stackchan-plan/ (HANDOFF.md; epics/E3-firmware-mvp.md; agreements-draft/requirements.md; agreements-draft/non-goals.md)
retrieved: 2026-07-25
method: export
collector: Claude Code session claude-child-t-e0-6 (T-E0-6, issue #12)
sensitivity: internal
status: raw
---

# StackChan hardware — seed excerpts from the plan-intake bundle

Verbatim excerpts of every plan-intake bundle passage that cites
`docs/context/stackchan-hw/` as its Source or defines the device/firmware
scope. The StackChan hardware survey (StackChan仕様調査) from the planning
session is still to be collected — see `INDEX.md` in this directory.
Everything below the section headings is quoted unedited (Japanese per
decision Q2).

## agreements-draft/requirements.md — row citing docs/context/stackchan-hw/

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-018 | 出荷時ファームウェアへ復元する手順を文書化し、少なくとも1回実証する | docs/context/stackchan-hw/ | 復元リハーサルの記録 | draft |

## agreements-draft/non-goals.md — rows citing docs/context/stackchan-hw/ (verbatim)

```markdown
- NG-006: 出荷時ファームウェア（XiaoZhiエコシステム）との互換維持はしない。カスタムファームに置き換える（復元手順は REQ-018 で担保）。(Source: docs/context/stackchan-hw/)
- NG-008: 5GHz Wi-Fi 対応はしない（ESP32-S3のハードウェア制約）。(Source: docs/context/stackchan-hw/)
```

## agreements-draft/requirements.md — related device-facing row (verbatim, cites the design sessions)

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-002 | StackChan (M5Stack K151) 実機で日本語の音声会話が成立する（発話→応答音声の再生） | 同上 | E4 実機E2E試験・デモ動画 | draft |

## epics/E3-firmware-mvp.md — full body (verbatim)

```markdown
## Outcome

PlatformIOでビルドしたカスタムファームが実機StackChanで顔・サーボ・LEDを制御し、WSSでプロキシに接続して音声を送受できる。出荷時ファームへ戻す保険も実証済み。

## Success criteria

- [ ] PlatformIO雛形（board=CoreS3, StackChan-BSP/M5Unified等）とビルドのみのCI
- [ ] 顔表示・サーボ（Y軸5〜85°制約遵守）・RGB LED制御（BSP経由）
- [ ] WSSクライアント：30秒ping+指数バックオフ自動再接続、切断中は待機表情に縮退（REQ-008）
- [ ] マイク→PCM16/16kHz送信、受信PCM再生（スピーカー）
- [ ] デバイスキーの保持とhello認証（Azure資格情報は不保持）（REQ-005）
- [ ] 紐付け用QRコード表示画面（REQ-010の素地）
- [ ] 出荷時ファームウェア復元手順を1回実証し文書化（REQ-018）

## Scope & non-goals

- In scope: 上記MVP機能、実機での動作確認（書き込み系タスクは exec:ide ルーティング）
- Out of scope: ウェイクワード高度化、省電力最適化、BLEプロビジョニング（E5）

## Phase outline

1. PlatformIO雛形とBSP疎通（顔・サーボ・LED）
2. WSSクライアントとプロトコルv0実装
3. 音声I/O（送信/再生）
4. QR表示・縮退動作
5. 復元手順実証・実機総合試験

## References

- Requirements: REQ-002, REQ-005, REQ-008, REQ-010, REQ-018
- Decisions: ADR-0002（プロトコル）
```

## HANDOFF.md — the E0 pointer naming the material still to land (verbatim excerpt)

```markdown
- これまでの調査・設計成果（StackChan仕様調査／Azure・Foundry設計／プロトコルv0／LINEミニアプリ調査）を `docs/context/<topic>/` に来歴ヘッダ付きで投入。Claudeとの本会話ログもここに保存すると出典が閉じる。
```
