# Requirements

One row per verifiable requirement. IDs are permanent: never reuse or
renumber; supersede instead (`Status: superseded by REQ-###`). Every `REQ`
must be provable by a command or an observable behavior
(`.github/skills/context-distillation/SKILL.md`, Quality bar).

<!-- 初版ドラフト。E0の蒸留PRでレビューし、Status を draft -> accepted に更新のこと。
     Source の docs/context/design-sessions/2026-07-claude-planning/ は
     E0で投入する設計セッション記録（本ドラフトの出典元）を指す。 -->

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-001 | 2027-07-26 時点で贈呈可能：初期化済み実機＋説明カード＋外装が揃い、新規環境（未登録Wi-Fi）で電源投入から音声会話成立まで10分以内にセットアップできる | design-sessions/2026-07-claude-planning/ | E8 最終リハーサルのタイム計測記録 | draft |
| REQ-002 | StackChan (M5Stack K151) 実機で日本語の音声会話が成立する（発話→応答音声の再生） | 同上 | E4 実機E2E試験・デモ動画 | draft |
| REQ-003 | 応答レイテンシ（ユーザー発話終了→応答音声再生開始）が P50≤3.0s / P95≤6.0s（暫定値、E4で計測し必要なら合意改定） | 同上 | プロキシ計測ログの集計レポート | draft |
| REQ-004 | 会話用LLMはAzure AI Foundryのデプロイ経由のみとし、デバイスのファーム変更なしでモデル差し替え（デプロイ名/設定変更）ができる | 同上 + docs/context/azure-foundry/ | モデル差し替え無停止試験 | draft |
| REQ-005 | デバイスにはAzureの資格情報を一切保持しない。保持するのはデバイス個別キーのみ | 同上 | ファームコードレビュー＋フラッシュ内容確認 | draft |
| REQ-006 | プロキシ→Foundry の認証は Entra ID（Managed Identity）によるキーレスとする | docs/context/azure-foundry/ | Bicep/構成レビュー、APIキー不使用の確認 | draft |
| REQ-007 | デバイスキーは個別発行・個別失効ができる | design-sessions/2026-07-claude-planning/ | 失効後の接続拒否試験 | draft |
| REQ-008 | デバイスはWS切断時に指数バックオフで自動再接続し、切断中は縮退動作（待機表情）で安全に振る舞う | 同上 | 切断・クラウド停止試験 | draft |
| REQ-009 | iOSアプリで BLEプロビジョニング（Wi-Fi設定＋キー書込）・設定変更・会話ログ閲覧・遠隔操作ができる | 同上 | E5 実機E2E試験 | draft |
| REQ-010 | LINEミニアプリで QR紐付け・設定変更・会話ログ閲覧・遠隔操作ができる（iOSの部分集合） | docs/context/line-miniapp/ | E6 実機E2E試験（LIFFブラウザ iOS/Android） | draft |
| REQ-011 | ミニアプリの制約を理由に iOS アプリの機能を削減・遅延させない。機能パリティ表を単一ソースとして維持する | design-sessions/2026-07-claude-planning/ | パリティ表の差分レビュー（E6完了時） | draft |
| REQ-012 | 管理者認証は LINEアカウント（IDトークン検証）＋allowlist で行い、iOS/ミニアプリで共通とする | 同上 | 非allowlistユーザーの拒否試験 | draft |
| REQ-013 | 異常通知（オフライン・低バッテリー）を iOS には APNs、ミニアプリ利用者には LINE Messaging API で届ける | docs/context/line-miniapp/ | E7 通知実発火試験 | draft |
| REQ-014 | デバイス状態のリアルタイム配信は共通チャネル（Azure Web PubSub）で行い、全クライアントが購読できる | docs/context/azure-foundry/ | 複数クライアント同時購読試験 | draft |
| REQ-015 | 会話ログ・設定は Cosmos DB に保存し、管理者のみ閲覧できる | design-sessions/2026-07-claude-planning/ | 認可なしアクセスの拒否試験 | draft |
| REQ-016 | 秘密情報は Key Vault で管理し、リポジトリ・ファーム・クライアントに秘密を含めない | 同上 | secret スキャン＋構成レビュー | draft |
| REQ-017 | 月次ランニングコストに予算アラートを設定する（閾値はE1で決定し本表を更新） | 同上 | アラート発火試験・月次レポート | draft |
| REQ-018 | 出荷時ファームウェアへ復元する手順を文書化し、少なくとも1回実証する | docs/context/stackchan-hw/ | 復元リハーサルの記録 | draft |
| REQ-019 | 誕生日演出（初回起動メッセージ・専用ペルソナ・記念日応答）を搭載する | design-sessions/2026-07-claude-planning/ | E8 デモ確認 | draft |
