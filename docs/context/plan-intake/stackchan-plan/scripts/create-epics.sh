#!/usr/bin/env bash
# create-epics.sh — StackChanプロジェクトのEpic 9本 (E0..E8) を一括起票し、
# blocked-by 依存を配線し、(任意で) Projects(v2) ロードマップに日付を設定する。
#
# 前提:
#   - tt1スキャフォールド展開済みリポジトリのルートで実行すること
#   - scripts/setup-labels.sh 実行済み (label: type:epic が存在すること)
#   - 日付設定する場合: scripts/setup-project.sh init 済みでプロジェクト番号を控えていること
#   - GitHub CLI (gh) >= 2.94 (--blocked-by / --parent 対応) / gh auth login 済み
#
# Usage:
#   bash create-epics.sh [-R owner/repo] [--project <number>] [--dry-run]
#
#   -R, --repo     対象リポジトリ (省略時: カレントディレクトリのリポジトリ)
#   --project      Projects(v2) の番号。指定時は各Epicに Start/Target date を設定
#   --dry-run      gh を実行せずコマンドを表示するだけ
#
# Epic本文はこのスクリプトと同階層の ../epics/*.md を参照する。
# 冪等ではない（再実行すると重複起票される）。まず --dry-run を推奨。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EPIC_DIR="${SCRIPT_DIR}/../epics"

REPO="" PROJECT="" DRY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -R|--repo) REPO="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --dry-run) DRY=true; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not found" >&2; exit 1; }
GH_VER="$(gh --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
if [[ -n "$GH_VER" ]]; then
  OLDEST="$(printf '%s\n%s\n' "2.94.0" "$GH_VER" | sort -V | head -1)"
  [[ "$OLDEST" == "2.94.0" ]] || echo "warn: gh ${GH_VER} は 2.94.0 未満の可能性。--blocked-by が使えない場合は gh を更新してください" >&2
fi

REPO_ARGS=()
[[ -n "$REPO" ]] && REPO_ARGS=(--repo "$REPO")

# 形式: id|タイトル|本文ファイル|依存(空白区切りid)|start|target
EPICS=(
  "E0|E0: スキャフォールド適用と知識蒸留|E0-scaffold-and-distill.md||2026-07-20|2026-08-31"
  "E1|E1: Azure基盤（IaC）|E1-azure-foundation.md|E0|2026-09-01|2026-09-30"
  "E2|E2: 中継プロキシMVP|E2-proxy-mvp.md|E1|2026-10-01|2026-11-15"
  "E3|E3: ファームウェアMVP|E3-firmware-mvp.md|E0|2026-10-15|2026-11-30"
  "E4|E4: E2E会話成立（★中間ゴール）|E4-e2e-conversation.md|E2 E3|2026-12-01|2026-12-28"
  "E5|E5: 管理API + iOSアプリα|E5-mgmt-api-ios-alpha.md|E4|2027-01-09|2027-03-14"
  "E6|E6: LINEミニアプリα|E6-line-miniapp-alpha.md|E5|2027-03-15|2027-04-25"
  "E7|E7: 通知・運用|E7-notify-ops.md|E6|2027-04-26|2027-05-31"
  "E8|E8: プレゼント仕上げ|E8-present-finish.md|E7|2027-06-01|2027-07-25"
)

SUMMARY=""

for entry in "${EPICS[@]}"; do
  IFS='|' read -r id title body deps start target <<<"$entry"
  BODY_PATH="${EPIC_DIR}/${body}"
  [[ -f "$BODY_PATH" ]] || { echo "error: body file not found: $BODY_PATH" >&2; exit 1; }

  # 依存idを起票済みissue番号へ解決 (bash 3.2互換のため間接展開を使用)
  DEP_NUMS=""
  for d in $deps; do
    var="NUM_${d}"
    dep_num="${!var:-}"
    [[ -n "$dep_num" ]] || { echo "error: dependency ${d} for ${id} is not created yet" >&2; exit 1; }
    DEP_NUMS="${DEP_NUMS}${DEP_NUMS:+,}${dep_num}"
  done

  ARGS=(--title "$title" --body-file "$BODY_PATH" --label "type:epic")
  [[ -n "$DEP_NUMS" ]] && ARGS+=(--blocked-by "$DEP_NUMS")

  if $DRY; then
    echo "[dry-run] gh issue create ${REPO_ARGS[*]:-} ${ARGS[*]}"
    [[ -n "$PROJECT" ]] && echo "[dry-run]   -> setup-project.sh dates --project $PROJECT --issue <n> --start $start --target $target"
    printf -v "NUM_${id}" '%s' "<${id}>"
    continue
  fi

  URL="$(gh issue create ${REPO_ARGS[@]+"${REPO_ARGS[@]}"} "${ARGS[@]}")"
  N="${URL##*/}"
  printf -v "NUM_${id}" '%s' "$N"
  echo "created ${id} -> #${N}  ${URL}"
  [[ -n "$DEP_NUMS" ]] && echo "  blocked by: ${DEP_NUMS}"

  if [[ -n "$PROJECT" ]]; then
    ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    SETUP="${ROOT}/scripts/setup-project.sh"
    if [[ -f "$SETUP" ]]; then
      bash "$SETUP" dates --project "$PROJECT" --issue "$N" \
        --start "$start" --target "$target" ${REPO:+-R "$REPO"}
    else
      echo "warn: ${SETUP} が見つからないため ${id} の日付設定をスキップ" >&2
    fi
  fi

  SUMMARY="${SUMMARY}${id}  #${N}  ${start} .. ${target}  ${title}\n"
done

echo
echo "== 起票サマリ =="
printf "%b" "$SUMMARY"
echo
echo "次の手順:"
echo "  1) Projects UI で Roadmap ビューを作成し、軸に Start date / Target date を選択（tt1側の一次手順に従う）"
echo "  2) E0 の Task 分解から着手（.github/prompts/breakdown-epic.prompt.md / new-task.sh を使用）"
