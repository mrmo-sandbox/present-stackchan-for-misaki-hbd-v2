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
