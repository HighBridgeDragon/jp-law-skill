#!/bin/bash
set -e

# キーワード検索 — GET /keyword
# Usage: bash scripts/search-keyword.sh <keyword> [limit]
# Example: bash scripts/search-keyword.sh 損害賠償 10

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KEYWORD="$1"
LIMIT="${2:-10}"

if [ -z "$KEYWORD" ]; then
  echo "Usage: bash scripts/search-keyword.sh <keyword> [limit]" >&2
  exit 1
fi

source "$SCRIPT_DIR/lib/urlencode.sh"

ENCODED=$(urlencode "$KEYWORD")
curl -s "https://laws.e-gov.go.jp/api/2/keyword?keyword=${ENCODED}&limit=${LIMIT}"
