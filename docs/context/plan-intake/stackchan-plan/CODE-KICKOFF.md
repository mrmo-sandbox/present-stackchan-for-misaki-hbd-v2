---
source: Claude planning conversation (StackChan plan bundle v1 handoff)
retrieved: 2026-07-18
method: export
collector: Claude Code kickoff session (bundle committed 2026-07-18, commit 35c1f6f, per CODE-KICKOFF.md Step 5)
sensitivity: internal
status: raw
---

# CODE-KICKOFF — GitHub起票＆Project作成 実行ランブック（Claude Code用）

- 対象リポジトリ: `mrmo-sandbox/present-stackchan-for-misaki-hbd-v2`
- ゴール: tt1スキャフォールド適用 → ラベル/ルールセット/Projects(v2)作成 → Epic 9本起票（blocked-by依存＋日付設定）→ Roadmapビュー準備
- 実行原則:
  - 各ステップの「確認:」を実行し、結果を短く報告してから次へ進む。
  - **⚠STOP** と書かれた箇所では必ず停止し、人間の操作・承認を待つ。
  - `create-epics.sh` は**冪等ではない**。再実行前は必ず既存Epicの有無を確認。
  - 認証情報（トークン等）の入力を求められる場面はすべて人間に依頼する。

## Step 0 — 前提確認

```bash
pwd                    # リポジトリルートであること
git status --short     # クリーンであること（未コミットがあれば報告）
gh --version           # 2.94.0 以上
gh auth status         # ログイン済み・対象リポジトリに書き込み可
ls stackchan-plan/     # 本バンドルが展開済み（epics/ scripts/ agreements-draft/ が見える）
```
確認: すべて満たす。1つでも欠ければ **⚠STOP** して報告。

## Step 1 — tt1スキャフォールド適用（`AGENTS.md` が既にあればスキップ）

```bash
git clone --depth 1 https://github.com/mochan-tk/tt1 /tmp/tt1
rsync -a --exclude .git /tmp/tt1/ ./
```
続けて `README.md` を次の最小内容に**置き換える**（tt1のREADMEで上書きされているため。本格的なREADMEはE0で作成）:

```markdown
# present-stackchan-for-misaki-hbd-v2

みさきさんの誕生日（2027-07-26）に贈るStackChanプロジェクト。
運用ルール・エージェント規約は AGENTS.md / .github/ 配下（tt1スキャフォールド）を参照。
```

確認: `ls AGENTS.md scripts/setup-project.sh .github/skills` が存在。
コミット: `chore: apply tt1 scaffold` → push。

## Step 2 — ラベル作成

```bash
bash scripts/setup-labels.sh
```
確認: `gh label list | grep -E "type:epic|ai:ready|exec:"` で10種のうち主要ラベルが見える。

## Step 3 — ルールセット

```bash
bash scripts/setup-ruleset.sh
```
権限不足等で失敗した場合はエラー内容を報告して**続行してよい**（起票には必須でない。E0で再訪）。

## Step 4 — Projects(v2) 初期化

```bash
bash scripts/setup-project.sh init
```
確認: 出力された**プロジェクト番号とURL**を控えて報告。以後 `<PROJECT_NUM>` とする。

## Step 5 — バンドルをリポジトリに格納（来歴保全）

```bash
mkdir -p docs/context/plan-intake
mv stackchan-plan docs/context/plan-intake/
```
コミット: `docs(context): add plan intake bundle (epics + REQ/NG drafts)` → push。

## Step 6 — 起票dry-run

```bash
bash docs/context/plan-intake/stackchan-plan/scripts/create-epics.sh --dry-run
```
確認: 9行が出て、依存が E0→E1→E2 / E0→E3 / E2,E3→E4 / E4→E5→E6→E7→E8 になっている。
**⚠STOP** — dry-run結果を人間に見せ、GOをもらってから次へ。

## Step 7 — 本実行

```bash
bash docs/context/plan-intake/stackchan-plan/scripts/create-epics.sh --project <PROJECT_NUM>
```
確認: 「起票サマリ」の Epic番号対応表（E0..E8 → #n）を報告。

## Step 8 — 検証

```bash
gh issue list --label type:epic --limit 20        # 9件あること
gh issue view <E4の番号>                           # Blocked by に E2/E3 の2件
gh issue view <E8の番号>                           # Blocked by に E7
```
可能なら `gh project item-list <PROJECT_NUM> --owner <リポジトリowner>` で9件がボードに載っていることも確認。

## Step 9 — **⚠人間の手動ステップ**: Roadmapビュー作成

ProjectsのURLを提示し、人間に以下を依頼して完了報告を待つ:
「新規ビュー → Roadmap を作成し、日付フィールドに **Start date / Target date** を選択」
（tt1の一次手順どおり、ビュー作成のみUI手動）

## Step 10 — 終了報告

- Epic番号対応表（E0..E8 → issue番号）、Project URL、スキップ/未了事項（ruleset等）を整理して報告。
- 次セッションの入口: **E0のTask分解**（`.github/prompts/breakdown-epic.prompt.md` と `new-task.sh -p <E0番号>` を使用。分解対象はE0本文のPhase outline）。

## トラブル時

- 途中失敗からの再開: `gh issue list --label type:epic` で既存を確認し、**重複起票を避ける**（不足分のみ手動で `gh issue create --body-file ... --label type:epic --blocked-by ...`）。
- `--blocked-by` が未知フラグと言われたら gh が古い → 人間に `gh` 更新を依頼（⚠STOP）。
