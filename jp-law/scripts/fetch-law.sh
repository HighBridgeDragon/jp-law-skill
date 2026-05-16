#!/bin/bash
set -e

# 法令本文取得 — GET /law_data/{law_id}
# Usage: bash scripts/fetch-law.sh [--max-time SEC] <law_id> [elm]
# Example: bash scripts/fetch-law.sh 129AC0000000089 MainProvision-Article_709

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
ELM="$2"

if [ -z "$LAW_ID" ]; then
  echo "Usage: bash scripts/fetch-law.sh [--max-time SEC] <law_id> [elm]" >&2
  exit 1
fi

URL="https://laws.e-gov.go.jp/api/2/law_data/${LAW_ID}"
if [ -n "$ELM" ]; then
  ENCODED_ELM="${ELM//\[/%5B}"
  ENCODED_ELM="${ENCODED_ELM//\]/%5D}"
  URL="${URL}?elm=${ENCODED_ELM}"
fi

curl -s --max-time "$MAX_TIME" --connect-timeout 10 "$URL"
