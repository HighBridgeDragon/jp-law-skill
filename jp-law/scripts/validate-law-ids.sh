#!/bin/bash
set -e

# law_id検証スクリプト
# law-aliases.mdに記載された全law_idをe-Gov APIで検証する
# Usage: bash scripts/validate-law-ids.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIASES_FILE="${SCRIPT_DIR}/../references/law-aliases.md"
API_BASE="https://laws.e-gov.go.jp/api/2"

# 一時ファイルの初期化とクリーンアップ設定
RESPONSE_FILE=$(mktemp)
trap 'rm -f "$RESPONSE_FILE"' EXIT

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==========================================="
echo "law-aliases.md 法令ID検証スクリプト"
echo "==========================================="
echo ""

# ネットワーク接続確認
echo "ネットワーク接続を確認中..."
if ! curl -s --max-time 5 "https://laws.e-gov.go.jp/api/2/" > /dev/null 2>&1; then
  echo -e "${RED}エラー: e-Gov API にアクセスできません${NC}"
  echo ""
  echo "以下を確認してください:"
  echo "  - インターネット接続が有効か"
  echo "  - プロキシ設定が必要か"
  echo "  - ファイアウォールでブロックされていないか"
  echo ""
  echo "詳細: docs/validate-law-ids.md を参照"
  exit 1
fi
echo -e "${GREEN}✓ ネットワーク接続OK${NC}"
echo ""

# law-aliases.mdからlaw_idを抽出
# テーブル行のみ抽出: | xxx | xxx | `law_id` | の形式
LAW_IDS=$(grep '|' "$ALIASES_FILE" | \
  grep -v '^|---' | \
  grep -v '| 通称・略称 |' | \
  grep '`' | \
  sed -E 's/.*`([^`]+)`.*/\1/')

# 検証結果を格納する変数
TOTAL=0
SUCCESS=0
FAILED=0
FAILED_IDS=""
LAW_ID_COUNT=$(printf "%s\n" "$LAW_IDS" | awk 'NF {count++} END {print count + 0}')

echo "検証対象: ${LAW_ID_COUNT} 件の法令ID"
echo ""

# 各law_idを検証
for LAW_ID in $LAW_IDS; do
  TOTAL=$((TOTAL + 1))

  # APIエンドポイント: GET /law_revisions/{law_id}
  URL="${API_BASE}/law_revisions/${LAW_ID}"

  # HTTPステータスコードと応答内容を取得（一時ファイルを上書き利用）
  HTTP_CODE=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" "$URL")

  if [ "$HTTP_CODE" = "200" ]; then
    # 法令名を取得（簡易的なJSONパース、jq不要）
    LAW_TITLE=$(grep -o '"law_title"[[:space:]]*:[[:space:]]*"[^"]*"' "$RESPONSE_FILE" 2>/dev/null | sed -E 's/"law_title"[[:space:]]*:[[:space:]]*"//; s/"$//' | head -1 || true)
    if [ -z "$LAW_TITLE" ]; then
      LAW_TITLE="（法令名取得失敗）"
    fi

    echo -e "${GREEN}[OK]${NC} ${LAW_ID} - ${LAW_TITLE}"
    SUCCESS=$((SUCCESS + 1))
  else
    # エラーレスポンスを取得
    ERROR_MSG=$(grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' "$RESPONSE_FILE" 2>/dev/null | sed -E 's/"message"[[:space:]]*:[[:space:]]*"//; s/"$//' | head -1 || true)
    if [ -z "$ERROR_MSG" ]; then
      ERROR_MSG="（応答なし）"
    fi

    echo -e "${RED}[NG]${NC} ${LAW_ID} - HTTP ${HTTP_CODE} - ${ERROR_MSG}"
    FAILED=$((FAILED + 1))
    FAILED_IDS="${FAILED_IDS}${LAW_ID}"$'\n'
  fi

  # APIへの負荷を軽減するため、短い間隔をあける
  sleep 0.5
done

# 結果サマリー
echo ""
echo "==========================================="
echo "検証結果サマリー"
echo "==========================================="
echo "総件数: ${TOTAL}"
echo -e "${GREEN}成功: ${SUCCESS}${NC}"
echo -e "${RED}失敗: ${FAILED}${NC}"

if [ $FAILED -gt 0 ]; then
  echo ""
  echo "失敗したlaw_id:"
  printf "%s" "${FAILED_IDS}"
  exit 1
else
  echo ""
  echo -e "${GREEN}✓ すべての法令IDが有効です${NC}"
  exit 0
fi
