#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/dream-skin-macos.sh"

APP_PATH="$1"
PORT="$2"
while dream_skin_app_is_running "$APP_PATH"; do
  /bin/sleep 1
done
exec "$SCRIPT_DIR/start-dream-skin.command" --port "$PORT"
