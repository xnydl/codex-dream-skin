#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

PORT="${DREAM_SKIN_PORT:-9335}"
"$SCRIPT_DIR/check-dream-skin.command"
APP_PATH="$(dream_skin_find_app)"

if dream_skin_port_has_codex "$PORT"; then
  exec "$SCRIPT_DIR/start-dream-skin.command" --port "$PORT"
fi

/bin/mkdir -p "$DREAM_SKIN_STATE_ROOT"
/usr/bin/nohup /bin/zsh "$SCRIPT_DIR/wait-and-start-macos.sh" "$APP_PATH" "$PORT" \
  >>"$DREAM_SKIN_STATE_ROOT/launcher.log" 2>&1 &

if dream_skin_app_is_running "$APP_PATH"; then
  print -r -- "启动已排队。现在按 Command + Q 完全退出 Codex；皮肤会自动应用并重新打开 Codex。"
else
  print -r -- "正在启动 Codex Dream Skin。"
fi
