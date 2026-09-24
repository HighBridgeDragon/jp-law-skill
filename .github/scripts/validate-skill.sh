#!/bin/bash
set -euo pipefail

# Agent Skills 仕様への適合検証 — Release の事前ゲート
# Usage: bash .github/scripts/validate-skill.sh <skill-dir>
#
# 前提: frontmatter の name / description は単一行の plain scalar であること。
# ブロックスカラー（description: |）や次行への折り返しは assert_single_line で
# 失敗させる。これらを黙って受け入れると値を途中までしか読めず、上限超過を
# 検知しないまま通してしまい、ゲートとして機能しなくなるため。
#
# 文字数は必ず文字単位で数える。日本語を含む description をバイト単位で数えると
# 1.25 倍前後に膨らみ、上限内のものを超過と誤判定する。
export LC_ALL=C.UTF-8

SKILL_DIR="${1:?Usage: bash .github/scripts/validate-skill.sh <skill-dir>}"
SKILL_MD="$SKILL_DIR/SKILL.md"

# オープン仕様 / Skills API の上限。
# 公式 support 記事は claude.ai のアップローダの上限を 200 文字と記載するが、
# 2026-09-24 に 520 / 567 文字の skill が実際にアップロードを通ったため、
# 200 は実効値ではないと判断して検査しない。
SPEC_DESC_MAX=1024
SPEC_NAME_MAX=64
# 非圧縮の合計サイズ上限（30 MB）
SPEC_SIZE_MAX_KB=$((30 * 1024))

fail=0
err() { echo "ERROR: $*" >&2; fail=1; }

if [ ! -f "$SKILL_MD" ]; then
  echo "ERROR: $SKILL_MD が無い。zip のトップレベルフォルダ直下に SKILL.md が必要" >&2
  exit 1
fi

# CR を落としてから解析する。SKILL.md が CRLF で書かれていると行末の CR が
# 値に残り、wc -m が 1 文字多く数えて上限判定がずれるため。
frontmatter() {
  tr -d '\r' < "$SKILL_MD" |
    awk 'NR==1 && /^---[[:space:]]*$/ {f=1; next} f && /^---[[:space:]]*$/ {exit} f'
}
field() { frontmatter | sed -n "s/^$1: *//p" | head -1; }

# 単一行 plain scalar でなければ失敗させる（上記の前提を守らせる）
assert_single_line() {
  case "$2" in
    '|'*|'>'*)
      err "$1 が YAML のブロックスカラー。本スクリプトは単一行 plain scalar のみ対応する"
      return
      ;;
  esac
  if frontmatter | awk -v k="$1" 'prev && /^[[:space:]]/ {found=1; exit} {prev = ($0 ~ "^" k ": ")} END {exit !found}'; then
    err "$1 の値が次行へ折り返している。本スクリプトは単一行 plain scalar のみ対応する"
  fi
}

NAME=$(field name)
DESC=$(field description)
DIR_NAME=$(basename "$SKILL_DIR")

NAME_LEN=$(printf '%s' "$NAME" | wc -m)
DESC_LEN=$(printf '%s' "$DESC" | wc -m)
SIZE_KB=$(du -sk "$SKILL_DIR" | cut -f1)

echo "name: ${NAME} (${NAME_LEN} 文字) / description: ${DESC_LEN} 文字 / 非圧縮サイズ: ${SIZE_KB} KB"

[ -n "$NAME" ] || err "frontmatter に name が無い"
assert_single_line name "$NAME"
[ "$NAME" = "$DIR_NAME" ] || err "name (${NAME}) がディレクトリ名 (${DIR_NAME}) と一致しない。仕様は一致を要求する"
[ "$NAME_LEN" -le "$SPEC_NAME_MAX" ] || err "name が ${NAME_LEN} 文字。上限は ${SPEC_NAME_MAX} 文字"

[ -n "$DESC" ] || err "frontmatter に description が無い"
assert_single_line description "$DESC"
[ "$DESC_LEN" -le "$SPEC_DESC_MAX" ] || err "description が ${DESC_LEN} 文字。上限は ${SPEC_DESC_MAX} 文字"

[ "$SIZE_KB" -le "$SPEC_SIZE_MAX_KB" ] || err "非圧縮サイズが ${SIZE_KB} KB。上限は ${SPEC_SIZE_MAX_KB} KB"

# skill は Linux サンドボックス上で実行されるため、CRLF のシェルスクリプトは
# 実行時に `command not found` となって動かない。zip に混入させない。
# 検出は tr で CR バイトを直接数える。grep のパターンに CR を渡す方法は
# 環境によって誤検知するため使わない。
CRLF=""
while IFS= read -r script; do
  [ "$(tr -dc '\r' < "$script" | wc -c)" -eq 0 ] || CRLF="${CRLF} ${script}"
done < <(find "$SKILL_DIR" -name '*.sh' -type f)
[ -z "$CRLF" ] || err "CRLF のスクリプトがある。Linux 上で実行できないため LF にすること（.gitattributes の eol=lf を確認）:${CRLF}"

# metadata.version は release.yml がタグ名を生成する唯一のソース。形式が崩れた
# まま main に入ると不正なタグでリリースされるため、PR 段階で止める。
# 抽出と検証の実体は skill-version.sh に置き、release.yml と同じ parser を共有する。
if VERSION=$(bash "$(dirname "$0")/skill-version.sh" "$SKILL_DIR"); then
  echo "metadata.version: ${VERSION} → リリースタグ v${VERSION}"
else
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "NG: ${SKILL_DIR} に仕様違反がある" >&2
  exit 1
fi
echo "OK: ${SKILL_DIR} は Agent Skills 仕様に適合"
