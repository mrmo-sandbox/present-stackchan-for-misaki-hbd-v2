## Outcome

共通の管理APIが稼働し、iOSアプリからデバイスの初期セットアップ（BLE）〜日常管理（ペルソナ/モデル/ログ/遠隔操作）までが完結する。

## Success criteria

- [ ] 管理API（OpenAPI定義先行）：デバイス登録/設定CRUD/会話ログ/遠隔操作。LINE IDトークン検証+管理者allowlist認可（REQ-012, REQ-015）
- [ ] iOS：LINEログイン（LINE SDK）で管理APIにアクセスできる
- [ ] iOS：BLEプロビジョニング（Wi-Fi設定+デバイスキー書き込み）で新品状態→会話可能まで完了（REQ-009）
- [ ] iOS：ペルソナ編集・モデル切替・ログ閲覧・遠隔操作（首/LED/表情/テスト発話）（REQ-009）
- [ ] Web PubSub購読でデバイス状態（オンライン/バッテリー）をリアルタイム表示（REQ-014）
- [ ] OpenAPIからのクライアント生成をiOS/ミニアプリで共用できる構成

## Scope & non-goals

- In scope: 管理API本体、iOSアプリα（SwiftUIネイティブ）、BLEプロビジョニングのためのファーム追補
- Out of scope: ミニアプリ、APNs通知（E7）、App Store一般公開（NG-007）

## Phase outline

1. OpenAPI設計とAPI実装（認証・認可含む）
2. iOS骨格+LINEログイン
3. BLEプロビジョニング（ファーム側追補含む）
4. 管理UI（設定/ログ/リモコン）
5. リアルタイム状態表示・総合試験

## References

- Requirements: REQ-009, REQ-011, REQ-012, REQ-014, REQ-015
- Decisions: ADR-0004（認証）, ADR-0005（クライアント戦略）
