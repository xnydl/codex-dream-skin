#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

PORT="${DREAM_SKIN_PORT:-9335}"
UNINSTALL=0
while (( $# > 0 )); do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    *) print -u2 -- "未知参数: $1"; exit 64 ;;
  esac
done

NODE_PATH="$(dream_skin_require_node)"
dream_skin_stop_recorded_injector
if dream_skin_port_has_codex "$PORT"; then
  "$NODE_PATH" "$DREAM_SKIN_INJECTOR" --remove --port "$PORT" --timeout-ms 3000 >/dev/null 2>&1 || true
fi
/bin/rm -f "$DREAM_SKIN_STATE_PATH"

if (( UNINSTALL )); then
  /bin/rm -f \
    "$HOME/Applications/Codex Dream Skin.command" \
    "$HOME/Applications/Codex Dream Skin - Restore.command" \
    "$HOME/Desktop/Codex Dream Skin.command" \
    "$HOME/Desktop/Codex Dream Skin - Restore.command"
fi

print -r -- "Codex Dream Skin 已从当前 macOS Codex 窗口移除。官方应用和用户数据未修改。"
