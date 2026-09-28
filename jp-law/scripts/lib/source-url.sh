# shellcheck shell=bash
# このファイルは source で読み込む専用です。直接実行しないでください。
# e-Gov 参照 URL（出典）の出力
#
# 出典 URL は law_id から機械的に決まる。LLM に組み立てさせる限りハルシネーションの
# 余地が残るため、スクリプト側で生成して出力する。
# 出力先は stderr。stdout の raw JSON は指示／データ境界であり、混ぜ物をしない。
#
# Usage: source "$SCRIPT_DIR/lib/source-url.sh"
#        emit_source_url "$LAW_ID" ["$NOTE"]
#        emit_source_urls_from_json "$RESPONSE"

EGOV_LAW_URL_BASE="https://laws.e-gov.go.jp/law"

emit_source_url() {
  local law_id="$1" note="${2:-}"
  # law_id は外部 API 応答から拾う経路があるため、URL に埋める前に形式を検査する
  if [[ ! "$law_id" =~ ^[0-9A-Za-z]+$ ]]; then
    echo "警告: 想定外の形式の law_id のため出典 URL を出力しない: ${law_id}" >&2
    return 0
  fi
  echo "【出典】e-Gov法令検索 ${EGOV_LAW_URL_BASE}/${law_id}${note:+（${note}）}" >&2
}

# 応答 JSON に含まれる law_id すべてに対して出典 URL を出す。
# 簡易的な JSON パース（jq 不要）。validate-law-ids.sh と同じ手法を用いる。
emit_source_urls_from_json() {
  local response="$1"
  grep -o '"law_id"[[:space:]]*:[[:space:]]*"[^"]*"' <<<"$response" \
    | sed -E 's/.*"([^"]*)"$/\1/' \
    | awk '!seen[$0]++' \
    | while IFS= read -r law_id; do
        emit_source_url "$law_id"
      done
}
