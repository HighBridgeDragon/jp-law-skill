#!/bin/bash
# lib/law-text.sh の自己検査。ネットワークに触れず、固定の JSON から整形結果だけを確かめる。
# Usage: bash tests/test-law-text.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=jp-law/scripts/lib/law-text.sh
source "${REPO_ROOT}/jp-law/scripts/lib/law-text.sh"

FAILED=0

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

# 1. 条見出し・条名・第1項本文。条名と本文は全角空白で続ける（e-Gov の表示に合わせる）
JSON='{"law_info":{"law_id":"129AC0000000089","law_num":"明治二十九年法律第八十九号"},"law_full_text":{"tag":"Article","attr":{"Num":"709"},"children":[{"tag":"ArticleCaption","attr":{},"children":["（不法行為による損害賠償）"]},{"tag":"ArticleTitle","attr":{},"children":["第七百九条"]},{"tag":"Paragraph","attr":{"Num":"1"},"children":[{"tag":"ParagraphNum","attr":{},"children":[]},{"tag":"ParagraphSentence","attr":{},"children":[{"tag":"Sentence","attr":{"Num":"1","WritingMode":"vertical"},"children":["故意又は過失によって他人の権利を侵害した者は、損害を賠償する責任を負う。"]}]}]}]}}'
assert_eq "条見出し・条名・第1項" \
  "（不法行為による損害賠償）
第七百九条　故意又は過失によって他人の権利を侵害した者は、損害を賠償する責任を負う。" \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

# 2. law_full_text の外側（law_info / revision_info）のテキストは混ぜない
case "$(printf '%s' "$JSON" | law_full_text_to_text)" in
  *"明治二十九年"*) echo "[NG] law_info のテキストが混ざった"; FAILED=$((FAILED + 1)) ;;
  *) echo "[OK] law_full_text の外側は出力しない" ;;
esac

# 3. 号番号と第2項以降の項番号を保持する
JSON='{"law_full_text":{"tag":"Article","attr":{"Num":"95"},"children":[{"tag":"ArticleTitle","attr":{},"children":["第九十五条"]},{"tag":"Paragraph","attr":{"Num":"1"},"children":[{"tag":"ParagraphNum","attr":{},"children":[]},{"tag":"ParagraphSentence","attr":{},"children":[{"tag":"Sentence","attr":{},"children":["意思表示は、次に掲げる錯誤に基づくものは、取り消すことができる。"]}]},{"tag":"Item","attr":{"Num":"1"},"children":[{"tag":"ItemTitle","attr":{},"children":["一"]},{"tag":"ItemSentence","attr":{},"children":[{"tag":"Sentence","attr":{},"children":["意思表示に対応する意思を欠く錯誤"]}]}]}]},{"tag":"Paragraph","attr":{"Num":"2"},"children":[{"tag":"ParagraphNum","attr":{},"children":["２"]},{"tag":"ParagraphSentence","attr":{},"children":[{"tag":"Sentence","attr":{},"children":["前項の規定による意思表示の取消しは、次に掲げる場合に限る。"]}]}]}]}}'
assert_eq "項番号・号番号" \
  "第九十五条　意思表示は、次に掲げる錯誤に基づくものは、取り消すことができる。
一　意思表示に対応する意思を欠く錯誤
２　前項の規定による意思表示の取消しは、次に掲げる場合に限る。" \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

# 4. ルビ（Ruby）は親文字だけを残し、読み仮名（Rt）は落とす
JSON='{"law_full_text":{"tag":"ArticleCaption","attr":{},"children":["（失",{"tag":"Ruby","attr":{},"children":["踪",{"tag":"Rt","attr":{},"children":["そう"]}]},"の宣告）"]}}'
assert_eq "ルビの読み仮名を落とす" "（失踪の宣告）" \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

# 5. 章・節の見出しは行を分ける
JSON='{"law_full_text":{"tag":"MainProvision","attr":{},"children":[{"tag":"Chapter","attr":{"Num":"1"},"children":[{"tag":"ChapterTitle","attr":{},"children":["第一章　総則"]},{"tag":"Article","attr":{"Num":"1"},"children":[{"tag":"ArticleTitle","attr":{},"children":["第一条"]},{"tag":"Paragraph","attr":{"Num":"1"},"children":[{"tag":"ParagraphNum","attr":{},"children":[]},{"tag":"ParagraphSentence","attr":{},"children":[{"tag":"Sentence","attr":{},"children":["この法律は、個人情報の適正な取扱いについて定める。"]}]}]}]}]}]}}'
assert_eq "章見出し" \
  "第一章　総則
第一条　この法律は、個人情報の適正な取扱いについて定める。" \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

# 6. law_full_text を持たない応答（API のエラー JSON 等）では何も出さない
assert_eq "law_full_text なしの応答" "" \
  "$(printf '%s' '{"code":400004,"message":"法令IDが誤っています"}' | law_full_text_to_text)"

# 7. エスケープを含む文字列を復元する（引用符・逆斜線）。
#    JSON 上は \" と \\ の 2 つのエスケープを含む 1 つの文字列
JSON='{"law_full_text":{"tag":"Sentence","attr":{},"children":["引用符 \" と逆斜線 \\ を含む文"]}}'
assert_eq "エスケープの復元" '引用符 " と逆斜線 \ を含む文' \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

# 8. 逆斜線に文字 n が続く本文（JSON 上は \\n）を改行に化けさせない
JSON='{"law_full_text":{"tag":"Sentence","attr":{},"children":["逆斜線と文字 \\n が並ぶ場合"]}}'
assert_eq "逆斜線＋n を改行にしない" '逆斜線と文字 \n が並ぶ場合' \
  "$(printf '%s' "$JSON" | law_full_text_to_text)"

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "全テスト成功"
else
  echo "${FAILED} 件失敗"
  exit 1
fi
