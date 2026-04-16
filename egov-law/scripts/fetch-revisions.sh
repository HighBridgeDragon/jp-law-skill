#!/bin/bash
set -e

# 改正履歴取得 — GET /law_revisions/{law_id}
# Usage: bash scripts/fetch-revisions.sh <law_id>
# Example: bash scripts/fetch-revisions.sh 129AC0000000089

LAW_ID="$1"

if [ -z "$LAW_ID" ]; then
  echo "Usage: bash scripts/fetch-revisions.sh <law_id>" >&2
  exit 1
fi

curl -s "https://laws.e-gov.go.jp/api/2/law_revisions/${LAW_ID}"
