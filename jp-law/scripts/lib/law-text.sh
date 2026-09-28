# shellcheck shell=bash
# このファイルは source で読み込む専用です。直接実行しないでください。
# law_full_text（tag/attr/children の再帰ツリー）から条文テキストだけを取り出す
#
# 人が読むための出力であり、JSON の指示／データ境界を外す。既定の出力を raw JSON の
# ままにしているのはこのため。詳細は SKILL.md セキュリティ節を参照。
#
# Usage: source "$SCRIPT_DIR/lib/law-text.sh"
#        printf '%s' "$RESPONSE" | law_full_text_to_text
#
# jq を増やさず awk で走査する（依存は bash / curl / grep / sed / awk のまま）。
# RS に二重引用符を指定し、文字列の中身と構造（{}[]:,）を交互のレコードとして受け取る。
# 条番号・項番号・号番号は行頭に残し、続く本文を全角空白でつなぐ（e-Gov の表示に合わせる）。

law_full_text_to_text() {
  awk '
  BEGIN {
    RS = "\""
    # 行を改めて始めるタグ（見出し・条名・項番号・号番号など）
    split("LawNum LawTitle EnactStatement TOCLabel TOCPart TOCChapter TOCSection " \
          "TOCSubsection TOCDivision TOCArticle TOCSupplProvision TOCAppdxTableLabel " \
          "PartTitle ChapterTitle SectionTitle SubsectionTitle DivisionTitle " \
          "ArticleCaption ArticleTitle ParagraphCaption ParagraphNum ItemTitle " \
          "Subitem1Title Subitem2Title Subitem3Title Subitem4Title SupplProvisionLabel " \
          "AppdxTableTitle RelatedArticleNum TableStructTitle TableRow RemarksLabel " \
          "ArithFormula", blk, " ")
    for (i in blk) BLOCK[blk[i]] = 1
    # 閉じた後に全角空白を置くタグ（「第七百九条　故意又は…」の形にする）
    split("ArticleTitle ParagraphNum ItemTitle Subitem1Title Subitem2Title " \
          "Subitem3Title Subitem4Title RelatedArticleNum RemarksLabel TableColumn", ttl, " ")
    for (i in ttl) TITLE[ttl[i]] = 1
    lvl = 0; ftlvl = -1; active = 0; skiplvl = -1; ftpending = 0
    instr = 0; havestr = 0; pend = 0; out = 0; prevc = ""
  }

  # 末尾の逆斜線が奇数個なら、区切りになった引用符はエスケープされたもので文字列は続く
  function odd_bs(s,   n) {
    n = 0
    while (length(s) - n > 0 && substr(s, length(s) - n, 1) == "\\") n++
    return n % 2
  }

  function unesc(s) {
    if (index(s, "\\") == 0) return s
    gsub(/\\n/, "\n", s); gsub(/\\t/, "\t", s); gsub(/\\r/, "", s)
    gsub(/\\"/, "\"", s); gsub(/\\\//, "/", s); gsub(/\\\\/, "\\", s)
    # ponytail: \uXXXX は e-Gov が返さないため素通し。返すようになったら変換を足す
    return s
  }

  function emit(s) {
    s = unesc(s)
    if (s == "") return
    if (out) {
      if (pend == 2) printf "\n"
      else if (pend == 1) printf "　"
    }
    pend = 0; out = 1
    printf "%s", s
  }

  # 文字列レコードの用途を決める。直後が ":" ならキー、直前が ":" なら値、
  # そうでなければ（直前が "[" か ","）children 配列の中の本文テキスト
  function resolve(nc,   i, c) {
    i = 1; c = substr(nc, 1, 1)
    while (c == " " || c == "\t" || c == "\n" || c == "\r") { i++; c = substr(nc, i, 1) }
    if (c == ":") {
      lastkey[lvl] = strval
      if (strval == "law_full_text") ftpending = 1
      return
    }
    if (prevc == ":") {
      if (lastkey[lvl] != "tag") return
      TAG[lvl] = strval
      if (strval == "Rt" && skiplvl < 0) skiplvl = lvl
      if (active && BLOCK[strval]) pend = 2
      return
    }
    if (active && skiplvl < 0) emit(strval)
  }

  function scan(s,   i, n, c, endlvl, t) {
    n = length(s)
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (c == "{" || c == "[") {
        lvl++
        TAG[lvl] = ""; lastkey[lvl] = ""
        if (ftpending) { ftlvl = lvl; active = 1; ftpending = 0 }
      } else if (c == "}" || c == "]") {
        endlvl = lvl; t = TAG[endlvl]
        if (active && out && TITLE[t]) pend = 1
        TAG[endlvl] = ""; lastkey[endlvl] = ""
        lvl--
        if (skiplvl == endlvl) skiplvl = -1
        if (ftlvl >= 0 && lvl < ftlvl) active = 0
      }
      if (c != " " && c != "\t" && c != "\n" && c != "\r") prevc = c
    }
  }

  {
    if (instr) {
      strval = strval $0
      if (odd_bs($0)) { strval = strval "\"" ; next }
      instr = 0; havestr = 1
      next
    }
    if (havestr) { resolve($0); havestr = 0 }
    scan($0)
    instr = 1; strval = ""
  }

  END { if (out) printf "\n" }
  '
}
