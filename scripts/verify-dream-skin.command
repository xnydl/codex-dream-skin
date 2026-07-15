#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

PORT="${DREAM_SKIN_PORT:-9335}"
SCREENSHOT=""
while (( $# > 0 )); do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --screenshot) SCREENSHOT="$2"; shift 2 ;;
    *) print -u2 -- "未知参数: $1"; exit 64 ;;
  esac
done

NODE_PATH="$(dream_skin_require_node)"
ARGS=(--verify --port "$PORT")
[[ -z "$SCREENSHOT" ]] || ARGS+=(--screenshot "$SCREENSHOT")
exec "$NODE_PATH" "$DREAM_SKIN_INJECTOR" "${ARGS[@]}"
