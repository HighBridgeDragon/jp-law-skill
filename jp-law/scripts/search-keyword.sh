#!/bin/bash
set -e

# キーワード検索 — GET /keyword
# Usage: bash scripts/search-keyword.sh [--max-time SEC] <keyword> [limit]
# Example: bash scripts/search-keyword.sh 損害賠償 10

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

KEYWORD="$1"
LIMIT="${2:-10}"

if [ -z "$KEYWORD" ]; then
  echo "Usage: bash scripts/search-keyword.sh [--max-time SEC] <keyword> [limit]" >&2
  exit 1
fi

source "$SCRIPT_DIR/lib/urlencode.sh"

ENCODED=$(urlencode "$KEYWORD")
curl -s --max-time "$MAX_TIME" --connect-timeout 10 "https://laws.e-gov.go.jp/api/2/keyword?keyword=${ENCODED}&limit=${LIMIT}"
