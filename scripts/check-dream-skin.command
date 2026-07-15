#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

PORT="${DREAM_SKIN_PORT:-9335}"
[[ "$(/usr/bin/uname -s)" == "Darwin" ]] || { print -u2 -- "此脚本仅支持 macOS。"; exit 1; }
APP_PATH="$(dream_skin_find_app)" || { print -u2 -- "未找到 /Applications/ChatGPT.app 或 Codex.app。"; exit 1; }
NODE_PATH="$(dream_skin_require_node)"

if dream_skin_port_is_used "$PORT" && ! dream_skin_port_has_codex "$PORT"; then
  print -u2 -- "端口 $PORT 已被其他程序占用，请设置 DREAM_SKIN_PORT 使用其他端口。"
  exit 1
fi

VERSION="$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$APP_PATH/Contents/Info.plist" 2>/dev/null || print unknown)"
BUILD="$(/usr/bin/plutil -extract CFBundleVersion raw "$APP_PATH/Contents/Info.plist" 2>/dev/null || print unknown)"
print -r -- "Codex Dream Skin macOS 环境检查通过。"
print -r -- "App: $APP_PATH"
print -r -- "Version: $VERSION ($BUILD)"
print -r -- "Node: $($NODE_PATH -v)"
print -r -- "CDP: 127.0.0.1:$PORT"
