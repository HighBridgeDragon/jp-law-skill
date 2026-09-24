#!/bin/bash
set -euo pipefail

# SKILL.md の metadata.version を取り出す — バージョンの唯一のソース。
# Usage: bash .github/scripts/skill-version.sh <skill-dir>
#
# release.yml はこの値から `v<version>` というタグを生成する。配布 CLI
# (`gh skill install`) はタグ付きリリースを優先して解決するため、タグは
# 機能的な識別子である。人が別途タグを打つと SKILL.md とずれ、両者を読む
# 主体が違う（タグ = CLI、metadata.version = 人）ためずれても誰も気付かない。
# そこでタグを本値から機械生成し、編集点を SKILL.md の 1 行に集約する。
#
# 抽出と検証を 1 箇所に置くのは、validate-skill.sh（PR 段階のゲート）と
# release.yml（タグ生成）が同じ解釈を共有する必要があるため。

SKILL_MD="${1:?Usage: bash .github/scripts/skill-version.sh <skill-dir>}/SKILL.md"

[ -f "$SKILL_MD" ] || { echo "ERROR: $SKILL_MD が無い" >&2; exit 1; }

# CRLF で書かれていても値に CR が残らないよう先に落とす。
# metadata: ブロック直下（インデント 2）の version: のみを見る。
# 他ブロックに同名キーがあっても拾わないよう、ブロックの範囲を追跡する。
VERSION=$(
  tr -d '\r' < "$SKILL_MD" |
    awk '
      NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
      in_fm && /^---[[:space:]]*$/ { exit }
      in_fm && /^metadata:[[:space:]]*$/ { in_meta = 1; next }
      in_meta && /^[^[:space:]]/ { in_meta = 0 }
      in_meta && /^  version:[[:space:]]*/ {
        sub(/^  version:[[:space:]]*/, "")
        gsub(/^"|"$/, "")
        print
        exit
      }
    '
)

[ -n "$VERSION" ] || {
  echo "ERROR: $SKILL_MD の frontmatter に metadata.version が無い" >&2
  exit 1
}

# タグ名を機械生成する以上、形式が崩れると不正なタグが生える。semver に限定する。
printf '%s' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || {
  echo "ERROR: metadata.version (${VERSION}) が semver (x.y.z) でない" >&2
  exit 1
}

printf '%s\n' "$VERSION"
