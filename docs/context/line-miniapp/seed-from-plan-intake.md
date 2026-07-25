---
source: docs/context/plan-intake/stackchan-plan/ (HANDOFF.md; epics/E6-line-miniapp-alpha.md; agreements-draft/requirements.md; agreements-draft/non-goals.md)
retrieved: 2026-07-25
method: export
collector: Claude Code session claude-child-t-e0-6 (T-E0-6, issue #12)
sensitivity: internal
status: raw
---

# LINE mini-app — seed excerpts from the plan-intake bundle

Verbatim excerpts of every plan-intake bundle passage that cites
`docs/context/line-miniapp/` as its Source or defines the LINE mini-app scope.
The LINE mini-app survey (LINEミニアプリ調査) from the planning session is
still to be collected — see `INDEX.md` in this directory. Everything below the
section headings is quoted unedited (Japanese per decision Q2).

## agreements-draft/requirements.md — rows citing docs/context/line-miniapp/

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-010 | LINEミニアプリで QR紐付け・設定変更・会話ログ閲覧・遠隔操作ができる（iOSの部分集合） | docs/context/line-miniapp/ | E6 実機E2E試験（LIFFブラウザ iOS/Android） | draft |
| REQ-013 | 異常通知（オフライン・低バッテリー）を iOS には APNs、ミニアプリ利用者には LINE Messaging API で届ける | docs/context/line-miniapp/ | E7 通知実発火試験 | draft |

## agreements-draft/non-goals.md — row citing docs/context/line-miniapp/ (verbatim)

```markdown
- NG-003: LINEミニアプリの「認証済み」審査取得はMVPの必須条件にしない。未認証で運用開始する（審査は任意のstretch）。(Source: docs/context/line-miniapp/)
```

## epics/E6-line-miniapp-alpha.md — full body (verbatim)

```markdown
## Outcome

LINEミニアプリ（未認証）から、QR紐付け・設定変更・ログ閲覧・遠隔操作・状態ダッシュボードが使える。iOSの部分集合であり、iOS側の機能削減は発生していない。

## Success criteria

- [ ] ミニアプリチャネル作成（未認証）・エンドポイント設定・Scan QRオン、LIFF初期化と自動ログイン→IDトークンで管理API認可（REQ-012）
- [ ] `liff.scanCodeV2()` によるQR紐付けフロー：デバイスLCDのQR読取→クラウド経由で紐付け完了（REQ-010）
- [ ] 設定変更・ログ閲覧・遠隔操作UI（REQ-010）
- [ ] Web PubSub購読のリアルタイムダッシュボード（REQ-014）
- [ ] 機能パリティ表を更新し、iOS非削減を確認（REQ-011）
- [ ] 外部ブラウザでの動作確認（scanCode系を除くフォールバック挙動）

## Scope & non-goals

- In scope: 上記α機能、LIFFブラウザ実機検証（iOS/Android）
- Out of scope: 認証済み審査（NG-003）、サービスメッセージ、アプリ内課金（NG-004）

## Phase outline

1. チャネル/LIFF設定とログイン疎通
2. QR紐付けフロー
3. 管理UI移植（OpenAPI生成クライアント共用）
4. ダッシュボード
5. 実機検証・パリティ表更新

## References

- Requirements: REQ-010, REQ-011, REQ-012, REQ-014
- Decisions: ADR-0004, ADR-0005
```

## HANDOFF.md — the E0 pointer naming the material still to land (verbatim excerpt)

```markdown
- これまでの調査・設計成果（StackChan仕様調査／Azure・Foundry設計／プロトコルv0／LINEミニアプリ調査）を `docs/context/<topic>/` に来歴ヘッダ付きで投入。Claudeとの本会話ログもここに保存すると出典が閉じる。
```
