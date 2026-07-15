#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

PORT="${DREAM_SKIN_PORT:-9335}"
FOREGROUND=0
while (( $# > 0 )); do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --foreground-injector) FOREGROUND=1; shift ;;
    *) print -u2 -- "未知参数: $1"; exit 64 ;;
  esac
done

APP_PATH="$(dream_skin_find_app)" || { print -u2 -- "未找到 macOS Codex 应用。"; exit 1; }
NODE_PATH="$(dream_skin_require_node)"

if dream_skin_port_is_used "$PORT" && ! dream_skin_port_has_codex "$PORT"; then
  print -u2 -- "端口 $PORT 已被其他程序占用。"
  exit 1
fi

if ! dream_skin_port_has_codex "$PORT"; then
  if dream_skin_app_is_running "$APP_PATH"; then
    print -u2 -- "Codex 正在运行但未开启 Dream Skin 调试端口。请完全退出 Codex 后重新运行。"
    exit 2
  fi
  /usr/bin/open -na "$APP_PATH" --args \
    --remote-debugging-address=127.0.0.1 \
    --remote-debugging-port="$PORT"
fi

deadline=$(( EPOCHSECONDS + 30 ))
until dream_skin_port_has_codex "$PORT"; do
  (( EPOCHSECONDS < deadline )) || { print -u2 -- "Codex 未在 30 秒内开放本机 CDP 端口。"; exit 1; }
  /bin/sleep 0.4
done

dream_skin_stop_recorded_injector
/bin/mkdir -p "$DREAM_SKIN_STATE_ROOT"

if (( FOREGROUND )); then
  exec "$NODE_PATH" "$DREAM_SKIN_INJECTOR" --watch --port "$PORT"
fi

/usr/bin/nohup "$NODE_PATH" "$DREAM_SKIN_INJECTOR" --watch --port "$PORT" \
  >>"$DREAM_SKIN_LOG_PATH" 2>>"$DREAM_SKIN_ERROR_LOG_PATH" &
INJECTOR_PID=$!
dream_skin_write_state "$NODE_PATH" "$PORT" "$INJECTOR_PID" "$APP_PATH"

verified=0
for _ in {1..45}; do
  /bin/sleep 0.7
  if "$NODE_PATH" "$DREAM_SKIN_INJECTOR" --verify --port "$PORT" >/dev/null 2>&1; then
    verified=1
    break
  fi
done
(( verified )) || { print -u2 -- "皮肤已启动，但验证失败。日志：$DREAM_SKIN_ERROR_LOG_PATH"; exit 1; }
print -r -- "Codex Dream Skin 已在 macOS 启用。"
