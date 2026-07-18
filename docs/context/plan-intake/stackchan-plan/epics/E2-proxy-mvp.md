## Outcome

Container Apps上の中継プロキシが、デバイスキー認証済みのWSS接続に対して STT→LLM→TTS の応答音声を返し、モデル・ペルソナを無停止で差し替えられる。

## Success criteria

- [ ] WSS終端+デバイスキー認証（個別発行・個別失効）（REQ-005, REQ-007）
- [ ] プロトコルv0準拠（hello / audio.start / PCMバイナリ / audio.stop → speak.start / PCM / speak.stop、face・servo イベント）
- [ ] STT→LLM→TTSパイプラインがFoundryをキーレスで呼び出して動作（REQ-002の素地、REQ-006）
- [ ] 設定ホットリロード：デプロイ名（モデル）・ペルソナの変更が再起動なしで反映（REQ-004）
- [ ] セッション毎のトークン使用量・レイテンシ内訳がApp Insightsに記録される（REQ-003の計測素地）
- [ ] PC上の模擬クライアントで音声in→音声outのE2Eが通る
- [ ] 30秒pingによるWSSキープアライブ（CAの240秒タイムアウト対策）

## Scope & non-goals

- In scope: プロキシ本体、模擬クライアント、パイプライン抽象化（後日Realtimeモードを差し込める構造）
- Out of scope: 実機ファーム、管理API/クライアントUI、Realtimeモード実装

## Phase outline

1. WSサーバ骨格+認証+プロトコルv0実装
2. Foundry呼び出し（キーレス）とSTT→LLM→TTS結線
3. 設定ホットリロードとCosmos連携
4. 計測（トークン/レイテンシ）実装
5. 模擬クライアントE2E・負荷/切断試験

## References

- Requirements: REQ-002..REQ-008, REQ-015
- Decisions: ADR-0001, ADR-0002（プロトコル）, ADR-0003（パイプライン）
