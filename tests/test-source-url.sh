#!/bin/bash
# lib/source-url.sh の自己検査。ネットワークに触れずに URL 生成の分岐だけを確かめる。
# Usage: bash tests/test-source-url.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=jp-law/scripts/lib/source-url.sh
source "${REPO_ROOT}/jp-law/scripts/lib/source-url.sh"

FAILED=0

# stderr だけを取り出す。stdout へ漏れた場合は別途 assert_no_stdout で落とす
capture_stderr() { "$@" 2>&1 1>/dev/null; }
capture_stdout() { "$@" 2>/dev/null; }

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "[OK] ${label}"
  else
    echo "[NG] ${label}"
    echo "     expected: ${expected}"
    echo "     actual  : ${actual}"
    FAILED=$((FAILED + 1))
  fi
}

# 1. law_id だけを渡すと法令単位の出典 URL が stderr に 1 行出る
assert_eq "law_id のみ" \
  "【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/129AC0000000089" \
  "$(capture_stderr emit_source_url 129AC0000000089)"

# 2. stdout は汚さない（raw JSON のパイプラインを壊さないことがこの関数の前提）
assert_eq "stdout へ出さない" "" "$(capture_stdout emit_source_url 129AC0000000089)"

# 3. 注記を渡すと URL の後ろに括弧で付く
assert_eq "注記あり" \
  "【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/415AC0000000057（URL は法令全体を指す）" \
  "$(capture_stderr emit_source_url 415AC0000000057 "URL は法令全体を指す")"

# 4. 外部 API 由来の値がそのまま URL に混ざらない。想定外の law_id は URL にせず警告する
BAD=$(capture_stderr emit_source_url 'x" onclick="evil')
case "$BAD" in
  *"laws.e-gov.go.jp"*) echo "[NG] 不正な law_id を URL にした: ${BAD}"; FAILED=$((FAILED + 1)) ;;
  "") echo "[NG] 不正な law_id を黙って捨てた"; FAILED=$((FAILED + 1)) ;;
  *) echo "[OK] 不正な law_id を URL にせず警告する" ;;
esac

# 5. 応答 JSON からは law_id を拾い、重複は畳み、出現順を保つ
JSON='{"laws":[{"law_id":"413R00000001003"},{"law_id":"415AC0000000057"},{"law_id":"413R00000001003"}]}'
assert_eq "JSON から抽出・重複排除・順序保持" \
  "【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/413R00000001003
【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/415AC0000000057" \
  "$(capture_stderr emit_source_urls_from_json "$JSON")"

# 6. law_id を含まない応答（エラー JSON 等）では何も出さない
assert_eq "law_id なしの応答" "" \
  "$(capture_stderr emit_source_urls_from_json '{"message":"not found"}')"

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "全テスト成功"
else
  echo "${FAILED} 件失敗"
  exit 1
fi
