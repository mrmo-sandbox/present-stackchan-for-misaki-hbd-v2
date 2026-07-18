## Outcome

Bicepで再現可能なAzure基盤一式がデプロイされ、AI Foundryにモデルが論理デプロイ名で払い出され、Managed Identityによるキーレス疎通が確認済み。

## Success criteria

- [ ] Bicep一式：RG / Log Analytics / Application Insights / Key Vault / Cosmos DB / Container Apps環境 / Web PubSub / AI Foundryリソース（何度流しても同一結果になること）
- [ ] モデルデプロイ（論理名 `stackchan-chat` / `stackchan-stt` / `stackchan-tts`）が作成され、Entra IDトークン+curlで応答確認（REQ-004, REQ-006）
- [ ] Managed Identity + RBAC（Cognitive Services User / Key Vault Secrets User 等）構成済み
- [ ] 月次コスト予算とアラートが設定されている（REQ-017）
- [ ] デプロイ手順・破棄手順が docs に記録されている

## Scope & non-goals

- In scope: IaCとリソース払い出し、疎通確認、コスト管理の土台
- Out of scope: プロキシ/管理APIの実装、CI/CDの本格整備

## Phase outline

1. Bicep骨格とパラメータ設計（環境1面：prod兼dev）
2. コアリソース（監視・KV・Cosmos・CA環境・Web PubSub）
3. Foundryリソース+モデルデプロイ
4. MI/RBAC配線
5. 疎通試験・コストアラート・手順書

## References

- Requirements: REQ-004, REQ-006, REQ-016, REQ-017
- Decisions: ADR-0001（全体構成）
