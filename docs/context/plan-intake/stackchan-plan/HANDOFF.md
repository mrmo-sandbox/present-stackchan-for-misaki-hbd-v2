---
source: Claude planning conversation (StackChan plan bundle v1 handoff)
retrieved: 2026-07-18
method: export
collector: Claude Code kickoff session (bundle committed 2026-07-18, commit 35c1f6f, per CODE-KICKOFF.md Step 5)
sensitivity: internal
status: raw
---

# StackChan計画バンドル v1 — HANDOFF

みさきさん誕生日（**2027-07-26**）逆算の大枠計画一式。tt1スキャフォールドの書式・運用（Epic issueグラフ＋Projects(v2)ロードマップ）にそのまま乗る形で作成。

## 同梱物

```
stackchan-plan/
├── HANDOFF.md                     このファイル
├── epics/                         Epic本文 9本（tt1 epic-body.md 準拠、見出しは英語のまま）
│   ├── E0-scaffold-and-distill.md   スキャフォールド適用と知識蒸留
│   ├── E1-azure-foundation.md       Azure基盤（IaC）
│   ├── E2-proxy-mvp.md              中継プロキシMVP
│   ├── E3-firmware-mvp.md           ファームウェアMVP
│   ├── E4-e2e-conversation.md       E2E会話成立（★年末の中間ゴール）
│   ├── E5-mgmt-api-ios-alpha.md     管理API + iOSアプリα
│   ├── E6-line-miniapp-alpha.md     LINEミニアプリα
│   ├── E7-notify-ops.md             通知・運用
│   └── E8-present-finish.md         プレゼント仕上げ（リハ・バッファ内包）
├── scripts/
│   └── create-epics.sh            9本を一括起票＋blocked-by配線＋日付設定
└── agreements-draft/
    ├── requirements.md            REQ-001..019 初版（E0の蒸留PRの入力）
    └── non-goals.md               NG-001..008 初版（同上）
```

## スケジュール（Epicの日付スパン＝Projectsロードマップ入力）

| Epic | Start | Target | 依存(blocked-by) |
|---|---|---|---|
| E0 | 2026-07-20 | 2026-08-31 | — |
| E1 | 2026-09-01 | 2026-09-30 | E0 |
| E2 | 2026-10-01 | 2026-11-15 | E1 |
| E3 | 2026-10-15 | 2026-11-30 | E0（E2と並行） |
| E4 | 2026-12-01 | 2026-12-28 | E2, E3 |
| E5 | 2027-01-09 | 2027-03-14 | E4 |
| E6 | 2027-03-15 | 2027-04-25 | E5 |
| E7 | 2027-04-26 | 2027-05-31 | E6 |
| E8 | 2027-06-01 | 2027-07-25 | E7 |

E8末尾の 7/12〜7/25 は総合リハーサル＆バッファ（新機能凍結）。**7/26 贈呈**。
前提ペース：週末＋平日夜の趣味開発、実装はCodexで並列化。tt1の思想どおり日付は「一度きりの正解」ではなく、`setup-project.sh dates` の再実行と replan で安く更新する。

## 実行手順

1. `present-stackchan-for-misaki-hbd-v2` に tt1 を展開（テンプレート生成 or ファイル移植）し、コミット。
2. リポジトリルートで：`bash scripts/setup-labels.sh` → `bash scripts/setup-ruleset.sh` → `bash scripts/setup-project.sh init`（**出力されるプロジェクト番号を控える**）。
3. 本バンドルをどこかに展開し（例：リポジトリ外でも可）、まず dry-run：
   `bash stackchan-plan/scripts/create-epics.sh --dry-run`
4. 本実行：`bash stackchan-plan/scripts/create-epics.sh --project <番号>`
   （リポジトリ外から実行する場合は `-R <owner>/present-stackchan-for-misaki-hbd-v2` を付与。gh >= 2.94 / `gh auth login` 済みが前提）
5. Projects の UI で Roadmap ビューを作成し、軸に `Start date` / `Target date` を選択（tt1の一次手順どおり、ビュー作成のみ手動）。
6. E0 に着手：
   - `agreements-draft/` の2ファイルを `docs/agreements/` への **蒸留PR** の初版入力として使用（tt1の規律：マージ＝合意。Source列が指す docs/context 側の投入もE0のタスク）。
   - これまでの調査・設計成果（StackChan仕様調査／Azure・Foundry設計／プロトコルv0／LINEミニアプリ調査）を `docs/context/<topic>/` に来歴ヘッダ付きで投入。Claudeとの本会話ログもここに保存すると出典が閉じる。
   - epics/ のmdは起票後は不要（issueが正）。保管するなら `docs/context/plan-intake/` へ。

## 注意

- create-epics.sh は**冪等ではない**（再実行で重複起票）。必ず dry-run から。
- macOS 標準 bash 3.2 で動くよう連想配列は不使用。
- 実機書き込み系タスクは `exec:ide`、Codexデスクトップは `exec:app` 相当として読み替え（E0のonboardingで明文化）。
- レイテンシ等の暫定値（REQ-003）はE4で実測後に合意改定してよい。数字を守ることより、改定を記録することを優先。
