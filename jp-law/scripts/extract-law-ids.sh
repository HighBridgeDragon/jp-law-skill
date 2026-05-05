#!/bin/bash
# law_id一覧抽出スクリプト
# law-aliases.mdから全law_idを抽出して出力する
# Usage: bash scripts/extract-law-ids.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIASES_FILE="${SCRIPT_DIR}/../references/law-aliases.md"

echo "# law-aliases.md から抽出した法令ID一覧"
echo ""
echo "合計: $(grep '|' "$ALIASES_FILE" | grep -v '^|---' | grep -v '| 通称・略称 |' | grep '`' | wc -l) 件"
echo ""

# カテゴリごとに整理して出力
CURRENT_CATEGORY=""

while IFS= read -r line; do
  # カテゴリ見出しを検出（## で始まる行）
  if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
    CURRENT_CATEGORY="${BASH_REMATCH[1]}"
    echo ""
    echo "## ${CURRENT_CATEGORY}"
    echo ""
    continue
  fi

  # テーブル行を処理
  if [[ "$line" =~ \|.*\|.*\|.*\`([^\`]+)\`.*\| ]]; then
    LAW_ID="${BASH_REMATCH[1]}"
    # 通称・正式名称も抽出
    LAW_ALIAS=$(echo "$line" | cut -d'|' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    LAW_NAME=$(echo "$line" | cut -d'|' -f3 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "- \`${LAW_ID}\` - ${LAW_NAME}"
  fi
done < "$ALIASES_FILE"

echo ""
echo "---"
echo ""
echo "# 検証用コマンド例"
echo ""
echo "各law_idを個別に検証:"
echo '```bash'
echo 'bash scripts/fetch-revisions.sh 129AC0000000089'
echo '```'
echo ""
echo "全law_idを一括検証:"
echo '```bash'
echo 'bash scripts/validate-law-ids.sh'
echo '```'
