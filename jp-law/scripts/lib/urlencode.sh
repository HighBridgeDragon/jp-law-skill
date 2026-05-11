# shellcheck shell=bash
# このファイルは source で読み込む専用です。直接実行しないでください。
# URLエンコード共通関数
# Usage: source "$SCRIPT_DIR/lib/urlencode.sh"
#        ENCODED=$(urlencode "$RAW")

urlencode() {
  printf '%s' "$1" | od -An -tx1 | tr ' ' '\n' | grep . | while read -r hex; do
    case "$hex" in
      2d|2e|5f|7e|3[0-9]|[46][1-9a-f]|[57][0-9a]) printf "\\x${hex}" ;;
      *) printf "%%%s" "$hex" ;;
    esac
  done
}
