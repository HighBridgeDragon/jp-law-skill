#!/bin/bash
set -e

# 法令検索 — GET /laws
# Usage: bash scripts/search-laws.sh [--max-time SEC] <law_title> [limit]
# Example: bash scripts/search-laws.sh 個人情報保護 5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MAX_TIME=30

while [ $# -gt 0 ]; do
  case "$1" in
    --max-time)
      [ -n "$2" ] || { echo "--max-time requires a numeric argument" >&2; exit 1; }
      MAX_TIME="$2"
      shift 2
      ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

LAW_TITLE="$1"
LIMIT="${2:-10}"

if [ -z "$LAW_TITLE" ]; then
  echo "Usage: bash scripts/search-laws.sh [--max-time SEC] <law_title> [limit]" >&2
  exit 1
fi

source "$SCRIPT_DIR/lib/urlencode.sh"
source "$SCRIPT_DIR/lib/source-url.sh"

ENCODED=$(urlencode "$LAW_TITLE")
# 出典 URL を応答から生成するため、パイプせずいったん受け取る
RESPONSE=$(curl -s --max-time "$MAX_TIME" --connect-timeout 10 "https://laws.e-gov.go.jp/api/2/laws?law_title=${ENCODED}&limit=${LIMIT}")
printf '%s\n' "$RESPONSE"

# 出典 URL はスクリプトが出す。SKILL.md はこれをそのまま転記する（LLM に組み立てさせない）
emit_source_urls_from_json "$RESPONSE"
