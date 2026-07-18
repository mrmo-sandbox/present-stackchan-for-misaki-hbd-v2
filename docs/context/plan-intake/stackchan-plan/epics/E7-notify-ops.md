## Outcome

デバイス異常（オフライン/低バッテリー）が各クライアント利用者に届き、監視・コスト・秘密情報管理が「贈った後も回る」運用品質になっている。

## Success criteria

- [ ] iOS向けAPNsプッシュ通知（オフライン検知・低バッテリー）（REQ-013）
- [ ] ミニアプリ利用者向けLINE Messaging API通知+友だち追加導線（requestFriendship）（REQ-013）
- [ ] 監視ダッシュボード：セッション数/トークン消費/エラー率/レイテンシ
- [ ] コストアラートの実発火試験と月次レポート手順（REQ-017）
- [ ] 秘密情報監査：リポジトリsecretスキャン、Key Vault集約の確認（REQ-016）
- [ ] 障害時ランブック（プロキシ再起動・モデル切替・復元手順への導線）

## Scope & non-goals

- In scope: 通知2経路、監視・運用整備
- Out of scope: 新機能、SLA的な高可用構成（家庭用途の範囲でよい）

## Phase outline

1. 異常検知ロジック（プロキシ側）
2. APNs経路
3. LINE通知経路
4. 監視ダッシュボード・コスト
5. 監査とランブック

## References

- Requirements: REQ-013, REQ-016, REQ-017
- Decisions: ADR-0001
