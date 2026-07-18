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
