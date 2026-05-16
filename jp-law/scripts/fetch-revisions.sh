#!/bin/bash
set -e

# 改正履歴取得 — GET /law_revisions/{law_id}
# Usage: bash scripts/fetch-revisions.sh [--max-time SEC] <law_id>
# Example: bash scripts/fetch-revisions.sh 129AC0000000089

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

LAW_ID="$1"

if [ -z "$LAW_ID" ]; then
  echo "Usage: bash scripts/fetch-revisions.sh [--max-time SEC] <law_id>" >&2
  exit 1
fi

curl -s --max-time "$MAX_TIME" --connect-timeout 10 "https://laws.e-gov.go.jp/api/2/law_revisions/${LAW_ID}"
