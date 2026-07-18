## Outcome

tt1スキャフォールドが本リポジトリに適用・チューニングされ、これまでの設計知識（StackChan仕様調査・Azure/Foundry設計・プロトコルv0・LINEミニアプリ調査）が `docs/agreements/` の承認済み合意（REQ / NG / ADR / 用語集）になっており、E1以降を随時Task分解できる状態。

## Success criteria

- [ ] `setup-labels.sh` / `setup-project.sh init` / `setup-ruleset.sh` 実行済みで、Projects(v2)ロードマップにRoadmapビューが作成されている
- [ ] project-onboarding 完了：CUSTOMIZE箇所の解消、exec:* ルーティングを本プロジェクト構成（設計=Claude Desktop(Fable 5)=planner/orchestrator、実装=Codexデスクトップ(gpt-5.6luna)=exec:app相当、実機作業=exec:ide、exec:cloudは当面未使用）へ読み替えた記述が反映されている
- [ ] 既存の調査・設計成果が出典付きで `docs/context/` に投入済み（status: raw → distilled）
- [ ] `requirements.md`（REQ-001..019 初版）と `non-goals.md`（NG-001..008 初版）がPRレビューを経てマージ済み
- [ ] ADR-0001..0005 初版が accepted：全体構成 / デバイス⇄プロキシ プロトコルv0 / 音声パイプライン（初期はSTT→LLM→TTS、Realtimeは後付け）/ 認証（LINE ID基軸+allowlist）/ クライアント戦略（iOS主軸・ミニアプリ部分集合）
- [ ] プロトコルv0のメッセージスキーマが仕様ファイルとして確定し、E2/E3から参照可能

## Scope & non-goals

- In scope: スキャフォールド適用、知識の投入と蒸留、合意形成、E1のTask分解
- Out of scope: 実装コード、Azureリソースの作成、実機作業

## Phase outline

1. tt1展開とセットアップスクリプト実行（labels / project / ruleset、Roadmapビュー作成）
2. project-onboarding（ルーティング読み替え・検証コマンド確定）
3. docs/context への調査成果投入（トピック別ディレクトリ+INDEX.md+来歴ヘッダ）
4. agreements 蒸留PR（requirements / non-goals / glossary）
5. ADR-0001..0005 起草・承認
6. E1「Azure基盤」のTask分解（ai:ready 付与）

## References

- Requirements: REQ-001..REQ-019（agreements-draft/requirements.md を初版入力とする）
- Decisions: ADR-0001..0005（本Epicで起草）
