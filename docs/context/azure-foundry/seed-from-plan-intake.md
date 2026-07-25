---
source: docs/context/plan-intake/stackchan-plan/ (HANDOFF.md; epics/E1-azure-foundation.md; epics/E2-proxy-mvp.md; agreements-draft/requirements.md)
retrieved: 2026-07-25
method: export
collector: Claude Code session claude-child-t-e0-6 (T-E0-6, issue #12)
sensitivity: internal
status: raw
---

# Azure / Foundry — seed excerpts from the plan-intake bundle

Verbatim excerpts of every plan-intake bundle passage that cites
`docs/context/azure-foundry/` as its Source or defines the Azure/Foundry
scope. The underlying design notes (Azure/Foundry architecture, protocol v0)
from the planning session are still to be collected — see `INDEX.md` in this
directory. Everything below the section headings is quoted unedited (Japanese
per decision Q2).

## agreements-draft/requirements.md — rows citing docs/context/azure-foundry/

| ID | Requirement | Source | Verification hint | Status |
|---|---|---|---|---|
| REQ-004 | 会話用LLMはAzure AI Foundryのデプロイ経由のみとし、デバイスのファーム変更なしでモデル差し替え（デプロイ名/設定変更）ができる | 同上 + docs/context/azure-foundry/ | モデル差し替え無停止試験 | draft |
| REQ-006 | プロキシ→Foundry の認証は Entra ID（Managed Identity）によるキーレスとする | docs/context/azure-foundry/ | Bicep/構成レビュー、APIキー不使用の確認 | draft |
| REQ-014 | デバイス状態のリアルタイム配信は共通チャネル（Azure Web PubSub）で行い、全クライアントが購読できる | docs/context/azure-foundry/ | 複数クライアント同時購読試験 | draft |

## epics/E1-azure-foundation.md — full body (verbatim)

```markdown
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
```

## epics/E2-proxy-mvp.md — protocol v0 and Foundry-call criteria (verbatim excerpt)

```markdown
- [ ] プロトコルv0準拠（hello / audio.start / PCMバイナリ / audio.stop → speak.start / PCM / speak.stop、face・servo イベント）
- [ ] STT→LLM→TTSパイプラインがFoundryをキーレスで呼び出して動作（REQ-002の素地、REQ-006）
- [ ] 設定ホットリロード：デプロイ名（モデル）・ペルソナの変更が再起動なしで反映（REQ-004）
- [ ] 30秒pingによるWSSキープアライブ（CAの240秒タイムアウト対策）
```

## HANDOFF.md — the E0 pointer naming the material still to land (verbatim excerpt)

```markdown
- これまでの調査・設計成果（StackChan仕様調査／Azure・Foundry設計／プロトコルv0／LINEミニアプリ調査）を `docs/context/<topic>/` に来歴ヘッダ付きで投入。Claudeとの本会話ログもここに保存すると出典が閉じる。
```
