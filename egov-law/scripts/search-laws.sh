#!/bin/bash
set -e

# 法令検索 — GET /laws
# Usage: bash scripts/search-laws.sh <law_title> [limit]
# Example: bash scripts/search-laws.sh 個人情報保護 5

LAW_TITLE="$1"
LIMIT="${2:-10}"

if [ -z "$LAW_TITLE" ]; then
  echo "Usage: bash scripts/search-laws.sh <law_title> [limit]" >&2
  exit 1
fi

urlencode() {
  printf '%s' "$1" | od -An -tx1 | tr ' ' '\n' | grep . | while read -r hex; do
    case "$hex" in
      2d|2e|5f|7e|3[0-9]|[46][1-9a-f]|[57][0-9a]) printf "\\x${hex}" ;;
      *) printf "%%%s" "$hex" ;;
    esac
  done
}

ENCODED=$(urlencode "$LAW_TITLE")
curl -s "https://laws.e-gov.go.jp/api/2/laws?law_title=${ENCODED}&limit=${LIMIT}"
