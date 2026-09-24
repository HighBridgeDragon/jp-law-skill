#!/bin/bash
set -euo pipefail

# Agent Skills 仕様への適合検証 — Release の事前ゲート
# Usage: bash .github/scripts/validate-skill.sh <skill-dir>
#
# 文字数は必ず文字単位で数える。日本語を含む description をバイト単位で数えると
# 1.25 倍前後に膨らみ、上限に収まっているものを超過と誤判定する。
export LC_ALL=C.UTF-8

SKILL_DIR="${1:?Usage: bash .github/scripts/validate-skill.sh <skill-dir>}"
SKILL_DIR="${SKILL_DIR%/}"
SKILL_MD="$SKILL_DIR/SKILL.md"

# claude.ai のアップローダが課す description 上限。オープン仕様より厳しく、公式 support 記事のみが記載する。
# 実効値の確証が取れていないため、超過は警告に留めて Release は通す。
CLAUDE_AI_DESC_MAX=200
# オープン仕様 / Skills API の上限。こちらは根拠が一致しているため違反を失敗として扱う。
SPEC_DESC_MAX=1024
SPEC_NAME_MAX=64
# 非圧縮の合計サイズ上限（30 MB）
SPEC_SIZE_MAX_KB=$((30 * 1024))

fail=0
err() { echo "ERROR: $*" >&2; fail=1; }
warn() { echo "WARNING: $*" >&2; }

if [ ! -f "$SKILL_MD" ]; then
  echo "ERROR: $SKILL_MD が無い。zip のトップレベルフォルダ直下に SKILL.md が必要" >&2
  exit 1
fi

frontmatter() {
  awk 'NR==1 && /^---[[:space:]]*$/ {f=1; next} f && /^---[[:space:]]*$/ {exit} f' "$SKILL_MD"
}
field() { frontmatter | sed -n "s/^$1: *//p" | head -1; }

NAME=$(field name)
DESC=$(field description)
DIR_NAME=$(basename "$SKILL_DIR")

NAME_LEN=$(printf '%s' "$NAME" | wc -m)
DESC_LEN=$(printf '%s' "$DESC" | wc -m)
SIZE_KB=$(du -sk "$SKILL_DIR" | cut -f1)

echo "name: ${NAME} (${NAME_LEN} 文字) / description: ${DESC_LEN} 文字 / 非圧縮サイズ: ${SIZE_KB} KB"

[ -n "$NAME" ] || err "frontmatter に name が無い"
[ "$NAME" = "$DIR_NAME" ] || err "name (${NAME}) がディレクトリ名 (${DIR_NAME}) と一致しない。仕様は一致を要求する"
[ "$NAME_LEN" -le "$SPEC_NAME_MAX" ] || err "name が ${NAME_LEN} 文字。上限は ${SPEC_NAME_MAX} 文字"

[ -n "$DESC" ] || err "frontmatter に description が無い"
[ "$DESC_LEN" -le "$SPEC_DESC_MAX" ] || err "description が ${DESC_LEN} 文字。オープン仕様の上限は ${SPEC_DESC_MAX} 文字"
[ "$DESC_LEN" -le "$CLAUDE_AI_DESC_MAX" ] || warn "description が ${DESC_LEN} 文字。claude.ai のアップローダは ${CLAUDE_AI_DESC_MAX} 文字を上限として記載しており、アップロードが拒否される可能性がある"

[ "$SIZE_KB" -le "$SPEC_SIZE_MAX_KB" ] || err "非圧縮サイズが ${SIZE_KB} KB。上限は ${SPEC_SIZE_MAX_KB} KB"

if [ "$fail" -ne 0 ]; then
  echo "NG: ${SKILL_DIR} に仕様違反がある" >&2
  exit 1
fi
echo "OK: ${SKILL_DIR} は Agent Skills 仕様に適合"
