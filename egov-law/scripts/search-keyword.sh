#!/bin/bash
set -e

# キーワード検索 — GET /keyword
# Usage: bash scripts/search-keyword.sh <keyword> [limit]
# Example: bash scripts/search-keyword.sh 損害賠償 10

KEYWORD="$1"
LIMIT="${2:-10}"

if [ -z "$KEYWORD" ]; then
  echo "Usage: bash scripts/search-keyword.sh <keyword> [limit]" >&2
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

ENCODED=$(urlencode "$KEYWORD")
curl -s "https://laws.e-gov.go.jp/api/2/keyword?keyword=${ENCODED}&limit=${LIMIT}"
