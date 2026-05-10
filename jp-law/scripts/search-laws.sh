#!/bin/bash
set -e

# 法令検索 — GET /laws
# Usage: bash scripts/search-laws.sh <law_title> [limit]
# Example: bash scripts/search-laws.sh 個人情報保護 5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LAW_TITLE="$1"
LIMIT="${2:-10}"

if [ -z "$LAW_TITLE" ]; then
  echo "Usage: bash scripts/search-laws.sh <law_title> [limit]" >&2
  exit 1
fi

source "$SCRIPT_DIR/lib/urlencode.sh"

ENCODED=$(urlencode "$LAW_TITLE")
curl -s "https://laws.e-gov.go.jp/api/2/laws?law_title=${ENCODED}&limit=${LIMIT}"
